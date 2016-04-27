# coding: utf-8
#
# unobtainium-faraday
# https://github.com/jfinkhaeuser/unobtainium-faraday
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-faraday contributors.
# All rights reserved.
#
require 'spec_helper'
require 'json'

describe 'Unobtainium::Faraday::Driver' do
  it "passes unobtainium's interface checks" do
    expect do
      require 'unobtainium-faraday'
    end.to_not raise_error(LoadError)
  end

  it "can be created" do
    expect do
      ::Unobtainium::Driver.create(:faraday)
    end.to_not raise_error

    drv = ::Unobtainium::Driver.create(:faraday)
    expect(drv).to_not be_nil
  end

  it "can be created from an alias" do
    expect do
      ::Unobtainium::Driver.create(:api)
    end.to_not raise_error

    drv = ::Unobtainium::Driver.create(:api)
    expect(drv).to_not be_nil
  end

  it "can be created with a URI" do
    endpoint = 'http://apps.testinsane.com/rte'
    drv = ::Unobtainium::Driver.create(:api, uri: endpoint)
    expect(drv.options[:uri]).to eql endpoint
  end

  it "can be created with adapter parameters" do
    drv = ::Unobtainium::Driver.create(:api, connection: { response: :logger })
    expect(drv.options[:connection][:response]).to eql :logger
  end

  it "can perform GET requests without endpoint" do
    drv = ::Unobtainium::Driver.create(:api)
    res = drv.get 'http://apps.testinsane.com/rte/status/200'
    expect(res.status).to eql 200
  end

  it "can perform GET requests with endpoint" do
    endpoint = 'http://apps.testinsane.com/rte'
    drv = ::Unobtainium::Driver.create(:api, uri: endpoint)
    res = drv.get 'status/200'
    expect(res.status).to eql 200
  end

  it "can perform POST requests without endpoint" do
    drv = ::Unobtainium::Driver.create(:api)
    res = drv.post 'http://apps.testinsane.com/rte/status/200' do |req|
      req.headers['content-type'] = 'application/json; charset=utf-8'
      req.body = JSON.dump(foo: 42)
    end
    expect(res.status).to eql 200
    expect(res.body['foo']).to eql 42
  end

  it "can perform POST requests with endpoint" do
    endpoint = 'http://apps.testinsane.com/rte'
    drv = ::Unobtainium::Driver.create(:api, uri: endpoint)
    res = drv.post 'status/200' do |req|
      req.headers['content-type'] = 'application/json; charset=utf-8'
      req.body = JSON.dump(foo: 42)
    end
    expect(res.status).to eql 200
    expect(res.body['foo']).to eql 42
  end
end
