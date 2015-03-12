require "spec_helper"
require "rack/test"
include Rack::Test::Methods

describe Crono::Web do
  let(:app) { Crono::Web }

  before do
    @test_job_id = "Perform TestJob every 5 seconds"
    @test_job_log = "All runs ok"
    @test_job = Crono::CronoJob.create!(job_id: @test_job_id, log: @test_job_log)
  end

  after { @test_job.destroy }

  describe "/" do
    it "should show all jobs" do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include @test_job_id
    end

    it "should show a error mark when a job is unhealthy" do
      @test_job.update(healthy: false)
      get '/'
      expect(last_response.body).to include "Error"
    end
  end

  describe "/job/:id" do
    it "should show job log" do
      get "/job/#{@test_job.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to include @test_job_id
      expect(last_response.body).to include @test_job_log
    end

    it "should show a message about the unhealthy job" do
      @test_job.update(healthy: false)
      get "/job/#{@test_job.id}"
      expect(last_response.body).to include "An error occurs during the last execution of this job"
    end
  end
end