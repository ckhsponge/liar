
class ClooneysRunner
  def self.user
    users = YAML.load( File.read('users.yml') )
    puts users.inspect
    user_params_string = users[ARGV[0]]
    user_params = {}
    user_params_string.each_key {|k| user_params[k.to_s.intern] = user_params_string[k]} #symbolize hash
    raise "No user '#{ARGV[0]}'" unless user_params
    puts user_params.inspect
    user = Clooneys::User.sign_in( user_params )
    raise "Could not sign in" unless user
    user.skip_join = user_params[ :skip_join ]
    user.skip_create = user_params[ :skip_create ]

    configs = YAML.load( File.read('config.yml') )
    puts configs.inspect
    config_params = configs[ARGV[1]]
    if config_params
      Clooneys::Resource.site = "http://#{config_params['host']}"
      Clooneys::Resource.long_poll_host = "http://#{config_params['long_poll_host']}"
    end
    return user
  end
end
