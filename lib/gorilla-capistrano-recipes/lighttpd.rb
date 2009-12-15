configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do  
  namespace :deploy do
    desc "Restart the web server"
    task :restart, :roles => :app do
      run "lighty restart >/dev/null 2>&1"
    end
    
    desc "Stop the web server"
    task :stop, :roles => :app do
      run "lighty stop >/dev/null 2>&1"
    end
    
    desc "Start the web server"
    task :start, :roles => :app do
      run "lighty start >/dev/null 2>&1"
    end
  end
end