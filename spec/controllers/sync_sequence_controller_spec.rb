require 'spec_helper'

describe FBPi::SyncSequenceController do
  let(:bot) { FakeBot.new }
  let(:mesh) { FakeMesh.new }
  let(:message) do
    FBPi::MeshMessage.new from: '1234567890',
                          type: 'sync_sequence',
                          payload:{"command"=>
                            [{"_id"=>"553f8aa270726f4090000000",
                              "start_time"=>"2015-04-28T23:00:00.000Z",
                              "end_time"=>"2015-04-30T23:00:00.000Z",
                              "repeat"=>4,
                              "time_unit"=>"hourly",
                              "sequence"=>
                                { "name"=>"FARMBOT II: A New Hope",
                                  "steps"=>
                                    [{ "message_type" => "move_relative",
                                        "command" => {"x"=>"1100"} } ] } } ] }
  end
  let(:controller) { FBPi::SyncSequenceController.new(message, bot, mesh) }

  it "initializes" do
    controller.call
    msg = mesh.last.payload || {}
    raise msg[:error] if msg[:error]
    expect(mesh.last.type).to eq("sync_sequence")
  end

  it 'handles validation errors' do
    message.payload["command"].first["time_unit"] = "Not Correct"
    ctrl = FBPi::SyncSequenceController.new(message, bot, mesh)
    ctrl.call
    last_msg = mesh.last.payload
    expect(last_msg[:message_type]).to eq('error')
    expect(last_msg[:error]).to eq("Time Unit isn't an option")
  end
end
