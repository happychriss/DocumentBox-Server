module SecretManager

  def aws_s3_key
    Rails.application.credentials[:aws][:access_key_id]
  end

  def aws_s3_secret
    Rails.application.credentials[:aws][:secret_access_key]
  end

  def aws_s3_db_bucket
    Rails.application.credentials[Rails.env.to_sym][:aws_s3_db_bucket]
  end

  def aws_s3_bucket
    Rails.application.credentials[Rails.env.to_sym][:aws_s3_bucket]
  end

  def aws_region
    Rails.application.credentials[:aws][:region]
  end

  def aws_gpg_email_address
    Rails.application.credentials[Rails.env.to_sym][:gpg_email_address]
  end

  def db_postgres_pwd
    Rails.application.credentials[Rails.env.to_sym][:postgres_password]
  end
  def db_postgres_user
    Rails.application.credentials[Rails.env.to_sym][:postgres_user]
  end

end