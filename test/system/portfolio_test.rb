require "application_system_test_case"

class PortfolioTest < ApplicationSystemTestCase
  test "the page shows every project in a real browser" do
    visit root_path

    assert_selector "h1", text: "Alex McRitchie"
    assert_selector "article.project", count: Project.all.size
    assert_selector "html.js"
    assert_link "Live showcase", href: "https://rantly.mcritchie.studio"
  end

  test "a phone gets one column and no sideways scroll" do
    page.driver.browser.manage.window.resize_to(375, 800)
    visit root_path

    overflow = page.evaluate_script("document.documentElement.scrollWidth - document.documentElement.clientWidth")
    assert_equal 0, overflow, "the page scrolls sideways at 375 px"

    years = find("#cyvasse .project__years").native.rect
    body = find("#cyvasse .project__body").native.rect
    assert_operator years.y + years.height, :<=, body.y + 1, "the year sits above the card on a phone"
  end
end
