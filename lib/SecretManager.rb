module SecretManager

  def aws_s3_key
    Rails.application.credentials[:access_key_id]
  end

  def aws_s3_secret
    Rails.application.credentials[:secret_access_key]
  end

  def aws_s3_bucket
    Rails.application.credentials[:aws_s3_bucket]
  end

  def aws_gpg_email_address
    Rails.application.credentials[Rails.env.to_sym][:gpg_email_address]
  end

end