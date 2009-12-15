configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do  
  namespace :passenger do
    desc "Restart the web server"
    task :restart, :roles => :app do
      run "touch  #{current_release}/tmp/restart.txt"
    end

    [:start, :stop].each do |t|
      desc "#{t} task is a no-op with passenger"
      task t, :roles => :app do ; end
    end
  end

  namespace :deploy do
    desc "Restart the web server"
    task :restart do
      passenger::restart
    end

    desc "Start the web server"
    task :start do
      passenger::start
    end

    desc "Stop the web server"
    task :stop do
      passenger::stop
    end
  end
end