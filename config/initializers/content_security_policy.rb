Rails.application.config.content_security_policy do |policy|
  policy.sandbox 'allow-forms', 'allow-same-origin'
  policy.default_src :none
  policy.img_src     :self
  policy.style_src   :self
end
