require "oystercard"

describe Oystercard do

  let(:station) {double :station}

  describe "#balance" do
    it "responds to balance method" do
      expect(subject).to respond_to(:balance)
    end

    it "a new instance of an oystercard has a balance of 0" do
      expect(subject.balance).to eq(0)
    end
  end

  describe "#top_up" do
    it 'responds to top_up' do
      expect(subject).to respond_to(:top_up).with(1).argument
    end
    it 'when topping up a new oystercard with 10, balance increases to 10' do
      subject.top_up(10)
      expect(subject.balance).to eq(10)
    end
    it "raises an error when topping up will bring balance over 90" do
      expect { subject.top_up(100) }.to raise_error("Top-up declined! There is a card limit of #{Oystercard::CARD_LIMIT}.")
    end
  end

  describe "#touch_in" do
    it "responds to touch_in at a station as argument" do
      expect(subject).to respond_to(:touch_in).with(1).argument
    end

    it "expects in journey to be true after touching in" do
      subject.top_up(2)
      subject.touch_in(station)
      expect(subject).to be_in_journey
    end

    it "raises an error if balance is less than minimum fare" do
      expect{subject.touch_in(station)}.to raise_error "You need a balance of at least #{Oystercard::MIN_FARE} to travel."
    end
  end

  describe "#touch_out" do
    it "responds to touch_out" do
      expect(subject).to respond_to(:touch_out)
    end

    before { subject.top_up(2) } 
    before { subject.touch_in(station) } 

    it "expects in journey to be false after touching out" do
      subject.touch_out
      expect(subject).not_to be_in_journey
    end

    it "expects minimum fare to be deducted at touch out" do
      expect{subject.touch_out}.to change{subject.balance}.by(-Oystercard::MIN_FARE)
    end
  end

  describe '#entry_station' do
    before { subject.top_up(2) } 
    before { subject.touch_in(station) } 

    it 'shows entry station after touching in' do
      expect(subject.entry_station).to eq (station)
    end
    it 'shows entry station as nil after touching out' do 
      subject.touch_out
      expect(subject.entry_station).to eq nil
    end
  end

end
