class TrainerInvitationMailer < ApplicationMailer
  def invite(user)
    @user = user
    mail subject: "You're invited to join Rocket", to: user.email_address
  end
end
