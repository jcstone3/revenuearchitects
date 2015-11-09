class WickedRailtie < Rails::Railtie
  initializer "wicked_pdf.register" do |app|
    ActionController::Base.send :include, PdfHelper
    if Rails::VERSION::MINOR > 0
      ActionView::Base.send :include, WickedPdfHelper::Assets
    else
      ActionView::Base.send :include, WickedPdfHelper
    end
    Mime::Type.register 'application/pdf', :pdf
  end
 end
