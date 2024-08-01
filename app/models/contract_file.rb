class ContractFile < ApplicationRecord
  belongs_to :contract
  has_one_attached :file

  enum status: %i[uploading analyzing review_needed reviewed on_hold]

  DOCUMENT_TYPES = %w[Msa Nda Dpa Sla Eula Of].freeze
  validates :type, inclusion: { in: DOCUMENT_TYPES }

  after_commit :broadcast
  after_commit :push_redis_payload, if: -> { saved_change_to_status? && analyzing? }

  private

  def broadcast
    FileChannel.broadcast_to(contract.user, { id:, name: file.filename, type:, status: })
  end

  def push_redis_payload
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'), db: ENV.fetch('REDIS_DB', 1))
    redis_key = "contract-#{contract.public_id}-#{id}"
    account = contract&.user&.accounts&.first
    filename = file.filename.to_s
    redis.del(redis_key) if redis.exists?(redis_key)

    json = {}
    if Rails.env.development?
      docs = YAML.load_file("#{Rails.root}/config/seeds/documents.yml")
      json = docs.dig(filename, 'json')
    end
    # Using hmset to store the hash in Redis
    # Convert value to string before setting, otherwise #hmset will throw invalid param error in case on nil
    redis.hmset(
      redis_key,
      'id', id,
      'status', 'queued',
      'pages', '0',
      'time_to_process', '0.0',
      'json', json.to_json,
      'filename', filename,
      'extension', File.extname(filename),
      'do_file_id', file&.key.to_s,
      'company_name', account&.name.to_s,
      'alternative_company_name', account&.alternative_name.to_s,
      'company_url', account&.website.to_s
    )
  end
end
