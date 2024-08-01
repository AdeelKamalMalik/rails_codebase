class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.invite.subject
  #
  def contract_expiring(contract)
    @contract = contract
    @user = @contract.user

    mail(
      to: email_address_with_name(@user.email, @user.name),
      from: Jumpstart.config.support_email,
      subject: t(".subject", contract_id: @contract.id, days: (@contract.end_date - DateTime.now.to_date).to_i)
    )
  end
end
