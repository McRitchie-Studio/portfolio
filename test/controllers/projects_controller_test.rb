require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "the home page lists every project with its year, description and GitHub link" do
    get root_path
    assert_response :success

    Project.all.each do |project|
      assert_select "article##{project.slug}", 1, project.slug do
        assert_select "h3", text: project.name
        assert_select "time", text: project.years
        assert_select "p", text: project.description
        assert_select "a[href=?]", project.github, text: /GitHub/
      end
    end
  end

  test "live links open the showcase build, and rebuilds say so" do
    get root_path

    Project.all.select(&:live?).each do |project|
      assert_select "article##{project.slug} a[href=?]", project.live, 1, project.slug
    end
    Project.all.select(&:rebuild?).each do |project|
      assert_select "article##{project.slug}", text: /Showcase rebuild/, message: project.slug
    end
    assert_select "article#mcritchie-studio", text: /Showcase rebuild/, count: 0
  end

  test "projects without a live build show no live link" do
    get root_path

    Project.all.reject(&:live?).each do |project|
      assert_select "article##{project.slug} a[href*='mcritchie.studio']", 0, project.slug
    end
  end

  test "outbound links open safely in a new tab" do
    get root_path

    assert_select "a[target=_blank]" do |links|
      links.each { |link| assert_equal "noopener", link["rel"], link["href"] }
    end
  end

  test "projects appear newest first" do
    get root_path

    slugs = css_select("article.project").map { |node| node["id"] }
    assert_equal Project.all.map(&:slug), slugs
  end

  test "the page credits the original portfolio and sets no cookie" do
    get root_path

    assert_select "a[href=?]", "https://github.com/amcritchie/portfolio"
    assert_select "footer", text: /2017/
    assert_nil response.headers["set-cookie"]
  end

  test "the health check answers" do
    get rails_health_check_path
    assert_response :success
  end
end
