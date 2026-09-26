require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "the data file lists every project the portfolio promises" do
    assert_equal %w[
      mcritchie-studio cyvasse prisoners-dilemma rantly property-manager
      restaurant-evaluations google-search-position iron-ocean weekly-lock
    ].sort, Project.all.map(&:slug).sort
  end

  test "every project has a name, a year, a one-line description and a GitHub repo" do
    Project.all.each do |project|
      assert project.name.present?, "#{project.slug}: name"
      assert_kind_of Integer, project.year, "#{project.slug}: year"
      assert_includes 2014..2026, project.year, "#{project.slug}: year"
      assert project.description.present?, "#{project.slug}: description"
      assert_operator project.description.length, :<=, 160, "#{project.slug}: keep it to one line"
      refute_includes project.description, "\n", "#{project.slug}: one line"
      assert_match %r{\Ahttps://github\.com/[\w.-]+/[\w.-]+\z}, project.github, "#{project.slug}: github"
    end
  end

  test "slugs are unique" do
    slugs = Project.all.map(&:slug)
    assert_equal slugs.uniq, slugs
  end

  test "live links are https on mcritchie.studio" do
    live = Project.all.select(&:live?)
    assert_operator live.size, :>=, 5
    live.each do |project|
      host = URI(project.live).host
      assert_equal "https", URI(project.live).scheme, project.slug
      assert host == "mcritchie.studio" || host.end_with?(".mcritchie.studio"), "#{project.slug}: #{host}"
    end
  end

  test "the showcase rebuilds point at the subdomains being built for them" do
    expected = {
      "prisoners-dilemma" => "https://prisoners-dilemma.mcritchie.studio",
      "rantly" => "https://rantly.mcritchie.studio",
      "weekly-lock" => "https://weekly-lock.mcritchie.studio",
      "cyvasse" => "https://cyvasse.mcritchie.studio"
    }
    expected.each do |slug, url|
      project = Project.find(slug)
      assert_equal url, project.live, slug
      assert project.rebuild?, "#{slug} is a rebuild"
    end
    refute Project.find("mcritchie-studio").rebuild?, "the studio is the original, not a rebuild"
  end

  test "a project without a live link is not called a rebuild" do
    Project.all.reject(&:live?).each do |project|
      refute project.rebuild?, project.slug
    end
  end

  test "projects run newest first" do
    years = Project.all.map(&:year)
    assert_equal years.sort.reverse, years
  end

  test "the years label spans the project's active years" do
    assert_equal "2015–17", Project.find("restaurant-evaluations").years
    assert_equal "2014", Project.find("rantly").years
  end

  test "no contact details in the data" do
    text = Rails.root.join("config/projects.yml").read
    refute_match(/@[a-z0-9-]+\.[a-z]/i, text, "no email addresses")
    refute_match(/\(?\d{3}\)?[ .-]\d{3}[ .-]\d{4}/, text, "no phone numbers")
  end

  test "find raises on an unknown slug" do
    assert_raises(KeyError) { Project.find("nope") }
  end
end
