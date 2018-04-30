class TerraformUsersService
  def initialize users_terraform, groups_terraform
    @users_terraform = JSON.parse users_terraform
    @groups_terraform = JSON.parse groups_terraform
  end

  def add_user email
    resource_name = get_resource_name email
    users = @users_terraform.fetch 'resource'
    resource_names = users.map {|u| u['aws_iam_user'].keys }.flatten

    if resource_names.include? resource_name
      raise StandardError.new "User #{resource_name} is already present in the terraform"
    end

    users.push('aws_iam_user' => {
      resource_name => {
        'name' => email,
        'force_destroy' => true
      }
    })

    users.sort_by! { |u| u['aws_iam_user'].keys.first }
    JSON.pretty_generate(@users_terraform) + "\n"
  end

  def add_user_to_group email
    resource_name = "${aws_iam_user.#{get_resource_name email}.name}"
    group = @groups_terraform['resource']['aws_iam_group_membership']['crossaccountaccess-members']['users']
    if group.include? resource_name
      raise StandardError.new "#{resource_name} is already a member of the crossaccountaccess group in the terraform"
    end

    group.push resource_name
    group.sort!

    JSON.pretty_generate(@groups_terraform) + "\n"
  end

private

  def get_resource_name email
    email.split('@').first.gsub('.', '_')
  end
end