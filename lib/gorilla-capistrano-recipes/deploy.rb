configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do
  require "gorilla-capistrano-recipes/deepmodules"  
  default_run_options[:pty] = true
  set :ssh_options, { :forward_agent => true}
  set(:deploy_to) { "/home/#{user}/apps/#{application}" }
  set :use_sudo, false
  set :group_writable, false
  set :keep_releases, 3
  set :migrate_env, "password"
  
  set :scm, "git"
  set :deploy_via, :remote_cache
  set :git_shallow_clone, 1
  set :git_enable_submodules, 1
  
  namespace :deploy do
    desc "Keep only 3 releases"
    after "deploy:default" do
      cleanup
    end
    
    desc "clear cached copy, e.g. when changing submodule urls"
    task :clear_cached_copy do
      run <<-CMD
    rm -rf #{shared_path}/cached-copy
      CMD
    end
    
  end
  
  namespace :configs do
    desc "Create all config files in shared/config"
    task :copy_database_config do
      run "mkdir -p #{shared_path}/config"
      put database_yml, "#{shared_path}/config/database.yml"
    end

    desc "Link in the shared config files"
    task :link do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
  

end