require 'spec_helper'
require 'pp'
RSpec.describe Specko::Parser do
  let(:file_path) { File.join(File.dirname(__FILE__), '../../fixtures/user.rb')  }
  let(:file_str) { File.read(file_path) }
  let(:parser) { Specko::Parser.new }
  let(:str1) {
    %[
      class User < ActiveRecordBase
        has_secure_password
        has_many :posts
        has_many :comments, through: :posts
    ]
  }
  it { expect(file_str).to be_truthy }


  describe "#top_level" do
    it { expect(parser.top_level).to parse("class User") }
    it { expect(parser.top_level).to parse("class User < ActiveRecordBase") }
  end

  describe "#top_level_name" do
    it { expect(parser.top_level_name).to parse("Whatever") }
  end

  describe "#top_level_base" do
    it { expect(parser.top_level_base).to parse("< Whatever") }
  end

  describe "#properties" do
    it { expect(parser.properties).to parse("\t  has_many :posts\n")}
    it { expect(parser.properties).to parse(" has_many :posts\n")}
    it { expect(parser.properties).to parse("has_many :posts, foreign_key: :post_id\n")}
    it { expect(parser.properties).to parse("has_secure_password\n")}
    it { expect(parser.properties).to parse("  has_many :posts\nhas_many :comments, through: :posts\n")}
  end

  describe "#property" do
    it { expect(parser.property).to parse("has_secure_password")}
    it { expect(parser.property).to parse("has_many :posts")}
    it { expect(parser.property).to parse("has_many :posts, foreign_key: :post_id")}
    it { expect(parser.property).to parse("enum :posts, user_status: [:new]")}
  end

  describe "#method" do
    it { expect(parser.method).to parse("has_many")}
  end

  describe "#params" do
    it { expect(parser.params).to parse(":posts")}
    it { expect(parser.params).to parse(":posts, :new")}
    it { expect(parser.params).to parse(":posts, :new, type: :regular")}
    it { expect(parser.params).to parse(":posts, :new, type: :regular")}
  end

  describe "#param" do
    it { expect(parser.param).to parse(":post")}
    it { expect(parser.param).to parse("type: :new")}
    it { expect(parser.param).to parse("type: [:active, :suspended]")}
  end

  describe "#symbol" do
    it { expect(parser.symbol).to parse(":posts")}
  end

  describe "#string" do
    it { expect(parser.string).to parse("\"posts\"")}
  end

  describe "#key_value" do
    it { expect(parser.key_value).to parse("key: :value")}
    it { expect(parser.key_value).to parse("key: \"value\"")}
    it { expect(parser.key_value).to parse("key: 1")}
    it { expect(parser.key_value).to parse("key: true")}
    it { expect(parser.key_value).to parse("type: [:active, :suspended]")}
    it { expect(parser.key_value).to parse("type: []")}
  end


  describe "#array" do
    it { expect(parser.array).to parse("[]")}
    it { expect(parser.array).to parse("[1, 2, 3]")}
    it { expect(parser.array).to parse("[:active, 2, :new, :old]")}
    it { expect(parser.array).to parse("[:active, :suspended]")}
  end


  describe "#hash" do
    subject { parser.hash }
    it { is_expected.to parse("{}")}
    it { is_expected.to parse("{\"a\": 2, \"b\": [1,2,3]}")}
    it { is_expected.to parse("{a: \"a\", b: \"b\"}")}
    it { is_expected.to parse("{active: 1, new: 2, old: {a: \"a\", b: \"b\", c: \"c\"}}")}

    it { is_expected.to parse("{active: 1, new: 2, old: {a: \"a\", b: \"b\"}}")}
  end

  describe 'root' do
    it { expect(parser.parse_with_debug(file_str)).to be_truthy }
    it { expect(parser.parse(file_str)).to be_truthy }
    it { pp parser.parse(file_str) }
  end
end
