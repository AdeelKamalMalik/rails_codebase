class ProcessAnalysedDocumentsJob < ActiveJob::Base
  # Set the Queue as Default
  queue_as :default

  def perform
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'), db: ENV.fetch('REDIS_DB', 1))
    keys = redis.keys('contract-*')
    keys.each do |key|
      response = redis.hgetall(key)
      next unless (json = JSON.parse(response['json'] || '{}')).present? && response['processed']&.downcase != 'true'

      old_contract, file = get_contract_and_file(key)
      next if old_contract.nil? || file.nil?

      # if contract has vendor
      vendor = old_contract.vendor
      new_contract = old_contract unless old_contract.draft?

      if (!vendor.present? || !new_contract.present?) && old_contract.user.contract_limit_reached?
        file.update(status: :on_hold)
        ContractChannel.broadcast_to(old_contract.user, { action: 'limit_reached' })
        next
      end

      vendor ||= create_vendor(json, old_contract.user_id)
      new_contract ||= Contract.find_or_create_by(
        vendor_id: vendor.id, start_date: json['start_date'], end_date: json['end_date'], user_id: vendor.user_id
      )

      attrs = json.slice(*(file.attributes.keys & json.keys))
      attrs['contract_id'] = new_contract.id
      attrs['status'] = :review_needed
      file.update(attrs)

      new_contract.update(
        name: new_contract.name || "Contract #{vendor.contracts.count + 1}",
        status: new_contract.draft? ? :active : new_contract.status.to_sym,
        order_number: json['order_number'], currency_code: new_contract.contract_files.pluck(:currency).compact.last,
        purchase_order_required: new_contract.contract_files.pluck(:purchase_order_required).compact.last,
        billing_interval: new_contract.contract_files.pluck(:billing_frequency).compact.last,
        payment_terms: new_contract.contract_files.pluck(:payment_terms).compact.last,
        total_cost: new_contract.contract_files.sum(:tcv), annual_cost: new_contract.contract_files.sum(:acv),
        monthly_cost: new_contract.contract_files.sum(:acv)/12, review_input: :needs_review
      )
      create_products(json, new_contract.id)
      create_notification(file)
      broadcast_first_contract(new_contract.user)

      old_contract.destroy if old_contract.draft? && old_contract.contract_files.empty?
      redis.hset(key, 'processed', 'true')
      # redis.del(key) # make sure to uncomment this when finalising redis related stuff.
    end
  end

  private

  def broadcast_first_contract(user)
    return unless user.contracts.not_draft.count == 1

    ContractChannel.broadcast_to(user, { action: 'first_active_contract' })
  end

  def create_vendor(json, user_id)
    vendor = Vendor.find_or_initialize_by(vendor_url: json['vendor_url'], user_id: user_id)
    vendor.name = json['vendor_name']
    vendor.save
    vendor
  end

  def create_notification(contract_file)
    user, account = [contract_file.contract.user, contract_file.contract.user.accounts.last]
    NewContractNotification.with(contract_file:, account:).deliver(user)
  end

  def create_products(json, contract_id)
    Array(json['products']).each do |product|
      attrs = {
        contract_id:, name: product['product_name'], quantity: product['quantity'], sales_price: product['sales_price'],
        sales_tax: product['sales_tax'], unit: product['unit'], start_date: product['start_date'],
        discount: product['discount'], end_date: product['end_date'], notes: product['notes']
      }
      Product.create(attrs)
    end
  end

  def get_contract_and_file(key)
    contract_public_id, contract_file_id = key.split('-').last(2)
    [Contract.find_by(public_id: contract_public_id), ContractFile.find_by(id: contract_file_id)]
  end
end
