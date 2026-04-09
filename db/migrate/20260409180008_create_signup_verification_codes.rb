class CreateSignupVerificationCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :signup_verification_codes do |t|
      t.string :email, null: false
      t.string :code_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.integer :attempt_count, null: false, default: 0
      t.integer :resend_count, null: false, default: 0
      t.datetime :last_sent_at, null: false

      t.timestamps
    end

    add_index :signup_verification_codes, :email, unique: true
    add_index :signup_verification_codes, :expires_at
    add_check_constraint :signup_verification_codes, "attempt_count >= 0", name: "signup_verification_codes_attempt_count_non_negative"
    add_check_constraint :signup_verification_codes, "resend_count >= 0", name: "signup_verification_codes_resend_count_non_negative"
  end
end
