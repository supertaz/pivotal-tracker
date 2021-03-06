require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe PivotalTracker::Story do
  before do
    @project = PivotalTracker::Project.find(102622)
  end

  context ".all" do
    it "should return all stories" do
      @project.stories.all.should be_a(Array)
      @project.stories.all.first.should be_a(PivotalTracker::Story)
    end
  end

  context ".find" do
    it "should return the matching story" do
      @project.stories.find(4459994).should be_a(PivotalTracker::Story)
    end
  end

  context ".create" do
    it "should return the created story" do
      @project.stories.create(:name => 'Create Stuff').should be_a(PivotalTracker::Story)
    end
  end

  context ".attachments" do
    it "should return an array of attachments" do
      @story = @project.stories.find(4460598)
      @story.attachments.should be_a(Array)
      @story.attachments.first.should be_a(PivotalTracker::Attachment)
    end
  end

  context ".move_to_project" do
    before(:each) do
      @orig_net_lock = FakeWeb.allow_net_connect?
      FakeWeb.allow_net_connect = true
      @target_project = PivotalTracker::Project.find(103014)
      @movable_story = @project.stories.find(4490874)
    end

    it "should return an updated story from the target project when passed a PivotalTracker::Story" do
      target_story = @target_project.stories.find(4477972)
      response = @movable_story.move_to_project(target_story)
      response.project_id.should == target_story.project_id
    end

    it "should return an updated story from the target project when passed a PivotalTracker::Project" do
      response = @movable_story.move_to_project(@target_project)
      response.project_id.should == @target_project.id
    end

    it "should return an updated story from the target project when passed a String" do
      response = @movable_story.move_to_project('103014')
      response.project_id.should == 103014
    end

    it "should return an updated story from the target project when passed an Integer"do
      response = @movable_story.move_to_project(103014)
      response.project_id.should == 103014
    end

    after (:each) do
      @movable_story = @target_project.stories.find(4490874)
      response = @movable_story.move_to_project(102622)
      FakeWeb.allow_net_connect = @orig_net_lock
      response.project_id.should == 102622
    end
  end

  context ".new" do

    def story_for(attrs)
      story = @project.stories.new(attrs)
      @story = Hash.from_xml(story.send(:to_xml))['story']
    end

    describe "attributes that are not sent to the tracker" do

      it "should include id" do
        story_for(:id => 10)["id"].should be_nil
      end

      it "should include url" do
        story_for(:url => "somewhere")["url"].should be_nil
      end

      it "should include created_at" do
        story_for(:created_at => Time.now)["created_at"].should be_nil
      end

      it "should include accepted_at" do
        story_for(:accepted_at => Time.now)["accepted_at"].should be_nil
      end

    end

    describe "attributes that are sent to the tracker" do

      it "should include name" do
        story_for(:name => "A user should...")["name"].should == "A user should..."
      end

      it "should include description" do
        story_for(:description => "desc...")["description"].should == "desc..."
      end

      it "should include story_type" do
        story_for(:story_type => "feature")["story_type"].should == "feature"
      end

      it "should include estimate" do
        story_for(:estimate => 5)["estimate"].should == "5"
      end

      it "should include current_state" do
        story_for(:current_state => "accepted")["current_state"].should == "accepted"
      end

      it "should include requested_by" do
        story_for(:requested_by => "Joe Doe")["requested_by"].should == "Joe Doe"
      end

      it "should include owned_by" do
        story_for(:owned_by => "Joe Doe")["owned_by"].should == "Joe Doe"
      end

      it "should include labels" do
        story_for(:labels => "abc")["labels"].should == "abc"
      end

      it "should include other_id" do
        story_for(:other_id => 10)["other_id"].should == "10"
      end

      it "should include integration_id" do
        story_for(:integration_id => 1000)["integration_id"].should == '1000'
      end

      # the tracker returns 422 when this is included, even if it is not used
      # it "should include jira_id" do
      #   story_for(:jira_id => 10)["jira_id"].should == "10"
      # end
      #
      # it "should include jira_url" do
      #   story_for(:jira_url => "somewhere")["jira_url"].should == "somewhere"
      # end

    end

  end

end
