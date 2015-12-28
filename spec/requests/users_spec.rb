require 'rails_helper'

RSpec.describe "Users", type: :request do
  
  describe "signup" do
    
    before do
      visit new_user_path(locale: I18n.locale)
    end
    
    describe "new user form" do
      
      it "displays username field" do
        expect(page).to have_selector("label", text: I18n.t('common.username'))
        expect(page).to have_field("username")
      end
      
      it "displays password field" do
        expect(page).to have_selector("label", text: I18n.t('common.password'))
        expect(page).to have_field("user_entered_password")
      end
      
      it "displays password confirmation field" do
        expect(page).to have_selector("label", text: I18n.t('common.password_confirmation'))
        expect(page).to have_field("user_entered_password_confirmation")
      end
      
      it "displays email field" do
        expect(page).to have_selector("label", text: I18n.t('common.email'))
        expect(page).to have_field("user_email")
      end
      
      it "displays email confirmation field" do
        expect(page).to have_selector("label", text: I18n.t('common.email_confirmation'))
        expect(page).to have_field("user_email_confirmation")
      end
      
      it "displays real name field" do
        expect(page).to have_selector("label", text: I18n.t('common.real_name'))
        expect(page).to have_field("user_real_name")
      end
      
      it "displays recaptcha field" do
        expect(page).to have_selector("label", text: I18n.t('common.recaptcha'))
      end
      
      it "displays upload photo field" do
        expect(page).to have_selector("label", text: I18n.t('common.upload_photo'))
        expect(page).to have_field("photo_name")
      end
    end    
  end
  
  describe "login" do
    
    before do
      visit login_users_path(locale: I18n.locale)
    end
    
    describe "new user form" do
      
      it "displays username field" do
        expect(page).to have_selector("label", text: I18n.t('common.username'))
        expect(page).to have_field("username")
      end
      
      it "displays password field" do
        expect(page).to have_selector("label", text: I18n.t('common.password'))
        expect(page).to have_field("password")
      end
      
      it "displays a link for forgot password page" do
        expect(page).to have_selector("a[href='/#{I18n.locale}/users/forgot_password']", text: I18n.t('common.forgot_password_link'))
      end
      
      it "displays a link for sign up page" do
        expect(page).to have_selector("a[href='/#{I18n.locale}/users/new']", text: I18n.t('common.signup'))
      end      
    end    
  end
  
  describe "show" do
    
    describe "profile tab" do
      
      context "when the user access his page" do
      
        before do
          file = ActionDispatch::Http::UploadedFile.new(tempfile: File.new(Rails.root.join("spec/avatar/default_user.png")),
                                                        filename: File.basename(File.new(Rails.root.join("spec/avatar/default_user.png"))))
          @owner_user = User.first
          page.set_rack_session(user_id: @owner_user.id)
          visit user_path(locale: I18n.locale, id: @owner_user.id)        
        end
        
        it "displays real name of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.real_name'))
          expect(page).to have_selector("span", text: @owner_user.real_name)
        end
        
        it "displays user name of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.username'))
          expect(page).to have_selector("span", text: @owner_user.username)
        end
        
        it "displays registeration date of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.member_since'))
          expect(page).to have_selector("span", text: @owner_user.created_at)
        end
        
        it "displays last login date of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.last_login'))
          expect(page).to have_selector("span", text: @owner_user.last_login)
        end
        
        # cannot test this part because it uses ajax
        it "displays user photo"
        it "displays checkbox to delete user photo"
        
        it "displays an edit link for user profile" do
          expect(page).to have_selector("a[href='/#{I18n.locale}/users/#{@owner_user.id}/edit']", text: I18n.t('common.edit'))
        end
      end
          
      context "when the user access another user's page" do
        
        before do
          file = ActionDispatch::Http::UploadedFile.new(tempfile: File.new(Rails.root.join("spec/avatar/default_user.png")),
                                                        filename: File.basename(File.new(Rails.root.join("spec/avatar/default_user.png"))))          
          @owner_user = User.first
          @other_user = User.find(2)
          page.set_rack_session(user_id: @owner_user.id)
          visit user_path(locale: I18n.locale, id: @other_user.id)        
        end
        
        it "displays real name of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.real_name'))
          expect(page).to have_selector("span", text: @other_user.real_name)
        end
        
        it "displays user name of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.username'))
          expect(page).to have_selector("span", text: @other_user.username)
        end
        
        it "displays registeration date of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.member_since'))
          expect(page).to have_selector("span", text: @other_user.created_at)
        end
        
        it "displays last login date of user" do
          expect(page).to have_selector("strong", text: I18n.t('common.last_login'))
          expect(page).to have_selector("span", text: @other_user.last_login)
        end        
      end      
    end    
  end 
end
