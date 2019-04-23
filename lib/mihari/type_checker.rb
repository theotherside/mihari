# frozen_string_literal: true

require "addressable/uri"
require "email_address"
require "ipaddr"
require "public_suffix"

module Mihari
  class TypeChecker
    attr_reader :data

    def initialize(data)
      @data = data
    end

    # @return [true, false]
    def hash?
      md5? || sha1? || sha256? || sha512?
    end

    # @return [true, false]
    def ip?
      IPAddr.new data
      true
    rescue IPAddr::InvalidAddressError => _
      false
    end

    # @return [true, false]
    def domain?
      uri = Addressable::URI.parse("http://#{data}")
      uri.host == data && PublicSuffix.valid?(uri.host)
    rescue Addressable::URI::InvalidURIError => _
      false
    end

    # @return [true, false]
    def url?
      uri = Addressable::URI.parse(data)
      uri.scheme && uri.host && uri.path && PublicSuffix.valid?(uri.host)
    rescue Addressable::URI::InvalidURIError => _
      false
    end

    # @return [true, false]
    def mail?
      EmailAddress.valid? data
    end

    # @return [String, nil]
    def type
      return "hash" if hash?
      return "ip" if ip?
      return "domain" if domain?
      return "url" if url?
      return "mail" if mail?
    end

    # @return [String, nil]
    def self.type(data)
      new(data).type
    end

    private

    # @return [true, false]
    def md5?
      data.match? /^[A-Fa-f0-9]{32}$/
    end

    # @return [true, false]
    def sha1?
      data.match? /^[A-Fa-f0-9]{40}$/
    end

    # @return [true, false]
    def sha256?
      data.match? /^[A-Fa-f0-9]{64}$/
    end

    # @return [true, false]
    def sha512?
      data.match? /^[A-Fa-f0-9]{128}$/
    end
  end
end