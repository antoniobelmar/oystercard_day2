require "oystercard"

describe Oystercard do

  let(:station) { double :station }
  let(:journey) { double :journey }

  describe "#balance" do
    it "a new instance of an oystercard has a balance of 0" do
      expect(subject.balance).to eq(0)
    end
  end

  describe "#top_up" do
    it 'when topping up a new oystercard with 10, balance increases to 10' do
      subject.top_up(10)
      expect(subject.balance).to eq(10)
    end
    it "raises an error when topping up will bring balance over 90" do
      expect { subject.top_up(100) }.to raise_error("Top-up declined! There is a card limit of #{Oystercard::CARD_LIMIT}.")
    end
  end

  describe "#touch_in" do
    it "expects in journey to be true after touching in" do
      subject.top_up(2)
      subject.touch_in(station)
      expect(subject).to be_in_journey
    end

    it "raises an error if balance is less than minimum fare" do
      expect{subject.touch_in(station)}.to raise_error "You need a balance of at least #{Journey::MIN_FARE} to travel."
    end

    it "deducts penalty fare if touching in while in journey" do
      subject.top_up(10)
      subject.touch_in(station)
      p "HERE", subject.journey_history.last
      expect{ subject.touch_in(station) }.to change{subject.balance}.by(-Journey::PENALTY_FARE)
    end

  end

  describe "#touch_out" do
    before { subject.top_up(2) }

    it "expects in journey to be false after touching out" do
      subject.touch_out(station)
      expect(subject).not_to be_in_journey
    end

    it "expects minimum fare to be deducted at touch out" do
      subject.touch_in(station)
      expect{ subject.touch_out(station) }.to change{subject.balance}.by(-Journey::MIN_FARE)
    end

    it "expects penalty_fare to be deducted at touch out if not in journey" do
      expect{ subject.touch_out(station) }.to change{subject.balance}.by(-Journey::PENALTY_FARE)
    end

  end

  describe "#journey_history" do

    describe "#journeys on initializing and touch_in" do
      it "check journeys is an array" do
        expect(subject.journey_history).to be_kind_of(Array)
      end

      before { subject.top_up(10) }
      before { subject.touch_in(station) }

      it "stores entry station upon touch_in" do
        expect(subject.journey_history.last[:entry]).to eq(station)
      end

      it "stores exit station as nil upon touch_in" do
        expect(subject.journey_history.last[:exit]).to eq nil
      end
    end

    describe "#journeys on touch_out" do

      before { subject.top_up(10) }
      before { subject.touch_in(station) }
      before { subject.touch_out(station) }

      it "stores entry station and exit station when touching in and out" do
        expect(subject.journey_history).to include({ entry: station, exit: station })
      end

      it "checks that touching in and out creates one and only one journey" do
        expect(subject.journey_history.count).to eq(1)
      end

      it "stores entry_station as nil upon touch_out if not in journey" do
        subject.touch_out(station)
        expect(subject.journey_history.last[:entry]).to eq nil
      end

    end

  end

end
