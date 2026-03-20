require "application_system_test_case"

class ForcedPasswordChangeTest < ApplicationSystemTestCase
  test "trainer with pending status is forced to change password before accessing the app" do
    trainer = users(:acme_trainer_three)
    assert trainer.pending_password_change?

    sign_in_via_ui trainer

    assert_current_path edit_account_password_path

    fill_in I18n.t("account.passwords.edit.password_placeholder"), with: "newpassword123!"
    fill_in I18n.t("account.passwords.edit.password_confirmation_placeholder"), with: "newpassword123!"
    click_button_and_confirm I18n.t("account.passwords.edit.submit"), title: I18n.t("sessions.new.title")

    assert_text I18n.t("account.passwords.update.success")

    trainer.reload
    assert trainer.active?

    # Sign out and sign back in to verify no longer forced to change password
    sign_out_via_ui
    sign_in_via_ui trainer, password: "newpassword123!"
    assert_current_path root_path
  end
end
