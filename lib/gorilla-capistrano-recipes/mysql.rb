configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do  
  desc 'Dumps the production database to db/production_data.sql on the remote server'
  task :remote_db_dump, :roles => :db, :only => { :primary => true } do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")

    run "cd #{deploy_to}/#{current_dir} && " +
      "#{rake} RAILS_ENV=#{rails_env} db:database_dump --trace"
  end

  desc 'Loads the production database to db/production_data.sql on the remote server'
  task :remote_db_load, :roles => :db, :only => { :primary => true } do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")

    run "cd #{deploy_to}/#{current_dir} && " +
      "#{rake} RAILS_ENV=#{rails_env} db:production_data_load --trace"
  end

  desc 'Downloads db/production_data.sql from the remote production environment to your local machine'
  task :remote_db_download, :roles => :db, :only => { :primary => true } do
    download("#{deploy_to}/#{current_dir}/db/production_data.sql", "db/production_data.sql", :via => :scp)
  end

  desc 'Uploads db/production_data.sql to the remote production environment from your local machine'
  task :remote_db_upload, :roles => :db, :only => { :primary => true } do
    upload("db/development_data.sql", "#{deploy_to}/#{current_dir}/db/production_data.sql", :via => :scp)
  end

  desc 'Cleans up data dump file'
  task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do
    run "rm #{deploy_to}/#{current_dir}/db/production_data.sql"
  end

  desc 'Cleans up data dump file'
  task :remote_cache_cleanup, :roles => :app do
    run "rm -rf #{deploy_to}/#{current_dir}/cache/* ;true"
  end

  desc 'Dumps, downloads and then cleans up the production data dump'
  task :remote_db_runner do
    remote_db_dump
    remote_db_download
    remote_db_cleanup
  end

  desc 'Dumps, uploads and then cleans up the production data dump'
  task :local_db_runner do
    remote_db_upload
    remote_db_load
    remote_cache_cleanup
    remote_db_cleanup
  end
end