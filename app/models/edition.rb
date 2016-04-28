class Edition < ActiveRecord::Base
  STATES = %w(draft published review_requested ready unpublished).freeze

  acts_as_commentable

  belongs_to :guide, touch: true
  belongs_to :author, class_name: "User"

  has_one :approval

  belongs_to :content_owner, class_name: 'GuideCommunity'

  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }
  scope :review_requested, -> { where(state: 'review_requested') }
  scope :most_recent_first, -> { order('created_at DESC, id DESC') }

  validates_presence_of [:state, :phase, :description, :title, :update_type, :body, :author]
  validates_inclusion_of :state, in: STATES
  validates :change_note, presence: true, if: :major?
  validates :change_summary, presence: true, if: :major?
  validates :version, presence: true

  auto_strip_attributes(
    :title,
    :description,
    :body,
  )

  %w{minor major}.each do |s|
    define_method "#{s}?" do
      update_type == s
    end
  end

  STATES.each do |s|
    define_method "#{s}?" do
      state == s
    end
  end

  def can_request_review?
    return false if !persisted?
    return false if review_requested?
    return false if published?
    return false if ready?
    return false if unpublished?
    true
  end

  def can_be_approved?(by_user)
    return false if new_record?
    return false unless review_requested?
    author != by_user || ENV['ALLOW_SELF_APPROVAL'].present?
  end

  def can_be_published?
    return false if published?
    return false if !latest_edition?
    ready?
  end

  def can_discard_draft?
    return false if !persisted?
    return false if published?
    return false if unpublished?
    return true
  end

  def latest_edition?
    self == guide.latest_edition
  end

  def content_owner_title
    content_owner.try(:title)
  end

  def previously_published_edition
    @previously_published_edition ||= guide.editions.published.where("id < ?", id).order(id: :desc).first
  end

  def change_note_html
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      extensions = {
        autolink: true,
      },
    ).render(change_note)
  end

  def notification_subscribers
    [author, guide.latest_edition.author].uniq
  end

private

  def assign_publisher_href
    self.publisher_href = PUBLISHERS[publisher_title] if publisher_title.present?
  end

  def ready?
    state == 'ready'
  end
end
