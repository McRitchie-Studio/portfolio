# One project on the portfolio. There is no database: the list lives in
# config/projects.yml, is read once at boot and frozen. A malformed file
# raises at boot, so a bad edit fails the deploy instead of rendering a
# half-empty page.
Project = Data.define(:slug, :name, :year, :until, :description, :stack, :github, :live, :rebuild) do
  def self.all
    @all ||= load_file(Rails.root.join("config/projects.yml")).freeze
  end

  def self.find(slug)
    all.find { |project| project.slug == slug } or raise KeyError, "no project #{slug.inspect}"
  end

  def self.load_file(path)
    YAML.safe_load_file(path).map do |row|
      new(**row.symbolize_keys.reverse_merge(until: nil, stack: nil, live: nil, rebuild: false))
    end
  end

  # "2014", or "2015–17" for a project that ran across years.
  def years
    return year.to_s if self.until.nil? || self.until == year

    "#{year}–#{self.until.to_s.last(2)}"
  end

  def live? = live.present?

  def rebuild? = live? && rebuild == true

  def live_host = live && URI(live).host

  def github_path = URI(github).path.delete_prefix("/")
end
