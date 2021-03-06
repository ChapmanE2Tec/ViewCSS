import Quick
import Nimble
@testable import ViewCSS

class ViewCSSGenerateCSSTextProtocolSpec: QuickSpec {
    let manager = ViewCSSManager.shared

    override func spec() {
        ViewCSSGenerateCSSTextProtocolHelper.iterate { (klass:  UIView.Type) in
            let object = NSObject()
            let view = klass.init()
            var viewProtocol = view as! ViewCSSGenerateCSSTextProtocol
            let spanText = "some 🤷🏻‍♀️ <span class=\"color\">stuff</span>"
            let linkText = "some 🤷🏻‍♀️ <a class=\"color\" href=\"https://www.example.com\">stuff</a>"
            let expectedText = "some 🤷🏻‍♀️ stuff"
            let linkLocation = "some 🤷🏻‍♀️ ".utf16.count
            
            beforeEach {
                let css = [
                    "ns_object.view" : ["background-color" : "red", "color" : "#00FF00FF"],
                    ".color" : ["color" : "#0000FFFF"],
                    ]
                self.manager.setCSS(dict: css)
                object.css(object: view, class: "view")
            }
            
            describe("#cssText") {
                it("sets span text") {
                    viewProtocol.cssText = spanText
                    expect(viewProtocol.cssText).to(equal(expectedText))
                }
                
                it("sets link text") {
                    viewProtocol.cssText = linkText
                    expect(viewProtocol.cssText).to(equal(expectedText))
                }
            }
            
            describe("#cssText") {
                
                it("returns the attributed span text from the object") {
                    let generatedText = spanText.cssText(object: view)
                    expect(generatedText!.string).to(equal(expectedText))
                    
                    if let _ = view as? UIButton {
                        let attributes = generatedText!.attributes(at: 0, effectiveRange: nil)
                        expect(attributes.count).to(equal(1))
                        expect((attributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#00FF00FF"))
                        
                        let tagttributes = generatedText!.attributes(at: linkLocation, effectiveRange: nil)
                        expect(tagttributes.count).to(equal(1))
                        expect((tagttributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#0000FFFF"))
                    }
                    else {
                        let attributes = generatedText!.attributes(at: 0, effectiveRange: nil)
                        expect(attributes.count).to(equal(2))
                        expect((attributes[NSAttributedStringKey.backgroundColor] as! UIColor).toCSS).to(equal("#FF0000FF"))
                        expect((attributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#00FF00FF"))
                        
                        let tagttributes = generatedText!.attributes(at: linkLocation, effectiveRange: nil)
                        expect(tagttributes.count).to(equal(2))
                        expect((tagttributes[NSAttributedStringKey.backgroundColor] as! UIColor).toCSS).to(equal("#FF0000FF"))
                        expect((tagttributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#0000FFFF"))
                    }
                    
                }
                
                it("returns the attributed link text from the object") {
                    let generatedText = linkText.cssText(object: view)
                    expect(generatedText!.string).to(equal(expectedText))
                    
                    if let _ = view as? UIButton {
                        let attributes = generatedText!.attributes(at: 0, effectiveRange: nil)
                        expect(attributes.count).to(equal(1))
                        expect((attributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#00FF00FF"))
                        
                        let tagttributes = generatedText!.attributes(at: linkLocation, effectiveRange: nil)
                        expect(tagttributes.count).to(equal(2))
                        expect((tagttributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#0000FFFF"))
                        expect((tagttributes[NSAttributedStringKey.link] as! String)).to(equal("https://www.example.com"))
                    }
                    else {
                        let attributes = generatedText!.attributes(at: 0, effectiveRange: nil)
                        expect(attributes.count).to(equal(2))
                        expect((attributes[NSAttributedStringKey.backgroundColor] as! UIColor).toCSS).to(equal("#FF0000FF"))
                        expect((attributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#00FF00FF"))
                        
                        let tagttributes = generatedText!.attributes(at: linkLocation, effectiveRange: nil)
                        expect(tagttributes.count).to(equal(3))
                        expect((tagttributes[NSAttributedStringKey.backgroundColor] as! UIColor).toCSS).to(equal("#FF0000FF"))
                        expect((tagttributes[NSAttributedStringKey.foregroundColor] as! UIColor).toCSS).to(equal("#0000FFFF"))
                        expect((tagttributes[NSAttributedStringKey.link] as! String)).to(equal("https://www.example.com"))
                    }
                }
                
                it("returns the attributed text for the class") {
                    let generatedText = linkText.cssText(object: view)
                    expect(generatedText!.string).to(equal(expectedText))
                }
            }
        }
    }
}
