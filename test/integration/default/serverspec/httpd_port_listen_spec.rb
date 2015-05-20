require 'serverspec'

# Required by serverspec
set :backend, :exec

describe "httpd port" do
  it "is listening on port 80" do
    expect(port(80)).to be_listening
  end
end
