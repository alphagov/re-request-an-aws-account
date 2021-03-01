class TerraformUsersService
  def initialize users_terraform, groups_terraform
    @users_terraform_orig = JSON.parse users_terraform
    @users_terraform = JSON.parse users_terraform
    @groups_terraform_orig = JSON.parse groups_terraform
    @groups_terraform = JSON.parse groups_terraform
  end

  def add_users email_list_string
    terraform = @users_terraform
    split_email_list(email_list_string).each do |email|
      if email.length > 64 then
        raise EmailTooLongError.new
      end
      terraform = add_user terraform, email
    end

    if terraform == @users_terraform_orig
      raise StandardError.new 'No changes need to be made to the terraform - all the users are already added'
    end

    JSON.pretty_generate(terraform) + "\n"
  end

  def add_users_to_group email_list_string
    terraform = @groups_terraform
    split_email_list(email_list_string).each do |email|
      terraform = add_user_to_group terraform, email
    end

    if terraform == @groups_terraform_orig
      raise StandardError.new 'No changes need to be made to the terraform - all the users are already added'
    end

    JSON.pretty_generate(terraform) + "\n"
  end

  def remove_users(email_list_string)
    terraform = @users_terraform
    split_email_list(email_list_string).each do |email|
      terraform = remove_user terraform, email
    end

    if terraform == @users_terraform_orig
      raise StandardError.new 'No changes need to be made to the terraform - all the users are already removed'
    end

    JSON.pretty_generate(terraform) + "\n"
  end

  def remove_users_from_group(email_list_string)
    terraform = @groups_terraform
    split_email_list(email_list_string).each do |email|
      terraform = remove_user_from_group terraform, email
    end

    if terraform == @groups_terraform_orig
      raise StandardError.new 'No changes need to be made to the terraform - all the users are already removed'
    end
    JSON.pretty_generate(terraform) + "\n"
  end

  def assert_user_exists email
    resource_name = get_resource_name email
    users = @users_terraform.fetch 'resource'
    resource_names = users.map {|u| u['aws_iam_user'].keys }.flatten

    unless resource_names.include? resource_name
      raise UserDoesntExistError.new email
    end
  end

  private

  def split_email_list(email_list_string)
    email_list_string.split.flat_map { |x| x.split(',') }
  end

  def add_user terraform, email
    resource_name = get_resource_name email
    users = terraform.fetch 'resource'
    resource_names = users.map {|u| u['aws_iam_user'].keys }.flatten

    if resource_names.include? resource_name
      raise UserAlreadyExistsError.new email
    end

    users.push('aws_iam_user' => {
      resource_name => {
        'name' => email,
        'force_destroy' => true
      }
    })

    users.sort_by! { |u| u['aws_iam_user'].keys.first }
    terraform
  end

  def remove_user terraform, email
    resource_name = get_resource_name email
    users = terraform.fetch 'resource'
    resource_names = users.map {|u| u['aws_iam_user'].keys }.flatten

    unless resource_names.include? resource_name
      raise UserDoesntExistError.new email
    end

    users.select! { |user| !user['aws_iam_user'].has_key? resource_name }

    terraform
  end

  def add_user_to_group terraform, email
    resource_name = "${aws_iam_user.#{get_resource_name email}.name}"
    group = terraform['resource']['aws_iam_group_membership']['crossaccountaccess-members']['users']
    if group.include? resource_name
      Rails.logger.warn "#{resource_name} is already a member of the crossaccountaccess group in the terraform, skipping"
      return terraform
    end

    group.push resource_name
    group.sort!

    terraform
  end

  def remove_user_from_group terraform, email
    resource_name = "${aws_iam_user.#{get_resource_name email}.name}"
    group = terraform['resource']['aws_iam_group_membership']['crossaccountaccess-members']['users']
    unless group.include? resource_name
      Rails.logger.warn "#{resource_name} is already not a member of the crossaccountaccess group in the terraform, skipping"
      return terraform
    end

    group.select! {|x| x != resource_name}

    terraform
  end

  def get_resource_name email
    email.split('@').first.gsub('.', '_')
  end
end