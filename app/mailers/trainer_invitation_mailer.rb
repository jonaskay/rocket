class TrainerInvitationMailer < ApplicationMailer
  def invite(user)
    @user = user
    mail subject: t(".subject"), to: user.email_address
  end
end
