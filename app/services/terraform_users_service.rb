class TerraformUsersService
  def initialize initial_terraform
    @initial_terraform = JSON.parse initial_terraform
  end

  def add_user email
    resource_name = email.split('@').first.gsub('.', '_')
    users = @initial_terraform.fetch 'resource'
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
    JSON.pretty_generate @initial_terraform
  end
end