class Comment < ActiveRecord::Base
  def self.MAX_LENGTH
    40#숫자만 변경해주면 된다.
  end
  belongs_to :post
  validates :body, length: {maximum: self.MAX_LENGTH},
                   presence: true #빈 칸 안되고 40자
end
