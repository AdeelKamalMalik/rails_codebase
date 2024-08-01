class TwilioService
  class << self
    def start_verification(to)
      verification = client.verify.v2.services(ENV.fetch('TWILLIO_SERVICE_SID')).verifications.create(
        to: phone_number(to), channel: 'sms'
      )

    end

    def check_verification(to, code)
      client.verify.v2.services(ENV.fetch('TWILLIO_SERVICE_SID')).verification_checks.create(
        to: phone_number(to), code: code
      )
    end

    private

    def client
      @client ||= Twilio::REST::Client.new(ENV.fetch('TWILLIO_ACCOUNT_SID'), ENV.fetch('TWILLIO_AUTH_TOKEN'))
    end

    def phone_number(phone)
      alpha2 = phone[0..1]
      country = ISO3166::Country.new alpha2
      "+#{country.country_code}#{phone[2...]}"
    end
  end
end
