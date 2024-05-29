Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = "/clock.rb"

    # if File.exist?(schedule_file)
    #   schedule = YAML.load_file(schedule_file)

    #   Sidekiq::Cron::Job.load_from_hash!(schedule, source: "schedule")
    # end
  end
end
