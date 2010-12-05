desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  puts "running cron task"
  # Eliminate all but one version for all dates older than 2 weeks
 (Date::today - 14).downto( Version.first.created_at.to_date ) do |day|
    versions = Version.where('created_at > ? AND created_at <= ?', day-1, day)
    versions.select('DISTINCT(item_type)').each do |version|
      if versions.where(:item_type => version.item_type).count > 1
        puts "deleting #{versions.where(:item_type => version.item_type).count - 1} versions from #{version.item_type}"
        versions.where(:item_type => version.item_type)[0..-2].each {|v| v.destroy}
      end
    end
  end
end
