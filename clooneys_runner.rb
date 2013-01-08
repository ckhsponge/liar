#this is executed from ai.rb
class ClooneysRunner
  def self.user
    configs = YAML.load( File.read('config.yml') )
    puts configs.inspect
    config_params = configs[ARGV[1]]
    if config_params
      Clooneys::Resource.site = "http://#{config_params['host']}"
      Clooneys::Resource.long_poll_host = "http://#{config_params['long_poll_host']}"
      puts "HOST: #{Clooneys::Resource.site}"
    end

    users = YAML.load( File.read('users.yml') )
    puts users.inspect
    login = ARGV[0]
    logins = users.values.collect{|v| v['login']}
    puts "logins: #{logins}"
    user_params_string = users[login]
    raise "no user params found for '#{login}'" unless user_params_string
    user_params = {}
    user_params_string.each_key {|k| user_params[k.to_s.intern] = user_params_string[k]} #symbolize hash
    user_params[:no_play_logins] = logins.delete_if{|l| l==user_params[:login]}
    puts "Playing: #{user_params.inspect}"
    user = Clooneys::User.sign_in( user_params )
    raise "Could not sign in" unless user

    return user
  end
end
