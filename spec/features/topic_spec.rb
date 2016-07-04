require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "Topics", type: :feature do
  let(:api_double) { double(:publishing_api) }

  it "before creating a new topic it cannot be published" do
    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    expect(page).to_not have_button('Publish')
  end

  it "saves a draft topic" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
      .once
      .with(an_instance_of(String), be_valid_against_schema('service_manual_topic'))
    expect(api_double).to receive(:patch_links)
      .once
      .with(an_instance_of(String), an_instance_of(Hash))
    create(:guide, editions: [build(:edition, title: 'Guide 1')])
    create(:guide, editions: [build(:edition, title: 'Guide 2')])

    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    fill_in "Path", with: "/service-manual/something"
    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"
    check "Collapsed"
    click_button "Add Heading"
    fill_in "Heading Title", with: "The heading title"
    fill_in "Heading Description", with: "The heading description"
    click_button "Save"

    expect(page).to have_field('Title', with: 'The title')
    expect(page).to have_field('Description', with: 'The description')
    expect(page).to have_checked_field('Collapsed')

    expect(find_field("Heading Title").value).to eq "The heading title"
    expect(find_field("Heading Description").value).to eq "The heading description"
  end

  it "links to a preview from a saved draft" do
    create(:topic, title: 'Agile Delivery', path: '/service-manual/agile-delivery-topic')

    visit root_path
    click_link "Manage Topics"
    click_link "Agile Delivery"

    expect(page).to have_link('Preview', href: %r{/service-manual/agile-delivery-topic})
  end

  it "update a topic to save another draft" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
      .once
      .with(an_instance_of(String), be_valid_against_schema('service_manual_topic'))
    expect(api_double).to receive(:patch_links)
      .once
      .with(an_instance_of(String), an_instance_of(Hash))
    create(:topic, title: 'Agile Delivery')

    visit root_path
    click_link "Manage Topics"
    click_link "Agile Delivery"

    fill_in 'Description', with: 'Updated description'

    click_button 'Save'

    within('.alert') do
      expect(page).to have_content('Topic has been updated')
    end
    expect(page).to have_field('Description', with: 'Updated description')
  end

  it "publish a topic" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:publish).
      once
    topic = create(:topic, :with_some_guides)

    # When publishing a topic we also need to update the links for all the relevant
    # guides so that they can display which topic they're in.
    #
    # Expect that the batch operation to patch the links is called
    expect(GuideTaggerJob).to receive(:batch_perform_later)
      .with(topic)

    # Expect that the topic is attempted to be indexed for search
    topic_search_indexer = double(:topic_search_indexer)
    expect(topic_search_indexer).to receive(:index)
    expect(TopicSearchIndexer).to receive(:new) { topic_search_indexer }

    visit root_path
    click_link "Manage Topics"
    click_link topic.title

    click_on 'Publish'

    within('.alert') do
      expect(page).to have_content('Topic has been published')
    end
  end

  it 'displays validation messages when validation fails' do
    visit new_topic_path
    click_button 'Save'

    within '.full-error-list' do
      expect(page).to have_content "Path must be present and start with '/service-manual/'"
    end
  end
end

RSpec.describe "topic editor", type: :feature do
  it "can view topics" do
    Topic.create!(
      path: "/service-manual/topic1",
      title: "Topic 1",
      description: "A Description",
    )
    visit root_path
    click_link "Manage Topics"
    click_link "Topic 1"
    expect(page).to have_link "View", href: "http://www.dev.gov.uk/service-manual/topic1"
  end
end
