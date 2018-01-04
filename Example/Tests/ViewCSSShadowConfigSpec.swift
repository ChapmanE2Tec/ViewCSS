import Quick
import Nimble
@testable import ViewCSS

class ViewCSSShadowConfigSpec: QuickSpec {
    override func spec() {
        
        let color = UIColor(css: "blue")!
        
        describe("#setOpacity") {
            ViewCSSTypeHelper.test(name: "shadow opacity", types: [.number], routine: { (value: String) -> (Any?) in
                let config = ViewCSSShadowConfig()
                config.setOpacity(dict: ["shadow-opacity": value])
                return config.opacity
            })
        }
        
        describe("#fromCSS") {
            
            it("ignores everything if the h-shadow and v-shadow are not defined") {
                let css = ["text-shadow" : ""]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset).to(beNil())
                expect(config.radius).to(beNil())
                expect(config.color).to(beNil())
                expect(config.opacity).to(beNil())
            }
            
            it("ignores everything if only the h-shadow is defined") {
                let css = [ "text-shadow" : "20px"]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset).to(beNil())
                expect(config.radius).to(beNil())
                expect(config.color).to(beNil())
                expect(config.opacity).to(beNil())
            }
            
            it("sets the offset is the h-shadow and v-shadow are defined") {
                let css = [ "text-shadow" : "20px 40px"]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset).to(equal(CGSize(width: 20, height: 40)))
                expect(config.radius).to(beNil())
                expect(config.color).to(beNil())
                expect(config.opacity).to(equal(1.0)) // Defaults opacity to 1.0 since none was included
            }
            
            it("sets the radius") {
                let css = [ "text-shadow" : "20px 40px 5px"]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset).to(equal(CGSize(width: 20, height: 40)))
                expect(config.radius).to(equal(5.0))
                expect(config.color).to(beNil())
                expect(config.opacity).to(equal(1.0)) // Defaults opacity to 1.0 since none was included
            }
            
            it("sets the radius and the color") {
                let css = [ "text-shadow" : "20px 40px 5px " + color.toCSS]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset).to(equal(CGSize(width: 20, height: 40)))
                expect(config.radius).to(equal(5.0))
                expect(config.color?.toCSS).to(equal(color.toCSS))
                expect(config.opacity).to(equal(1.0)) // Defaults opacity to 1.0 since none was included
            }

            it("skips the radius and sets the color by") {
                let css = [ "text-shadow" : "20px 40px " + color.toCSS]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset) == CGSize(width: 20, height: 40)
                expect(config.radius).to(beNil())
                expect(config.color?.toCSS).to(equal(color.toCSS))
                expect(config.opacity).to(equal(1.0)) // Defaults opacity to 1.0 since none was included
            }

            it("overrides the default opacity") {
                let css = [ "text-shadow" : "20px 40px " + color.toCSS, "text-shadow-opacity" : "0.5"]
                let config = ViewCSSShadowConfig.fromCSS(dict: css, base: "text")
                expect(config.offset) == CGSize(width: 20, height: 40)
                expect(config.radius).to(beNil())
                expect(config.color?.toCSS).to(equal(color.toCSS))
                expect(config.opacity).to(equal(0.5))
            }
        }
        
        describe("#toCSS") {
            
            // Iterate through the different supported class type
            let klasses: [UIView.Type] = [UILabel.self, UITextField.self, UITextView.self, UIButton.self]
            for klass in klasses {
                ViewCSSShadowProtocolHelper.iterate(callback: { (view: UIView) in
                    let targetView: UIView
                    if let button = view as? UIButton { targetView = button.titleLabel! }
                    else { targetView = view }
                    
                    beforeEach {
                        targetView.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
                        targetView.layer.shadowColor = color.cgColor
                        targetView.layer.shadowRadius = 5.0
                        targetView.layer.shadowOpacity = 0.6
                    }
                    
                    it("prints the CSS for " + String(describing: klass)) {
                        let css = ViewCSSShadowConfig.toCSS(object: targetView, base: "text")
                        expect(css["text-shadow"]).to(equal("2px 3px 5px " + color.toCSS))
                        expect(css["text-shadow-opacity"]).to(equal("0.6"))
                    }
                    
                    it("skips the opacity when 1.0 for " + String(describing: klass)) {
                        targetView.layer.shadowOpacity = 1.0
                        let css = ViewCSSShadowConfig.toCSS(object: targetView, base: "text")
                        expect(css["text-shadow"]).to(equal("2px 3px 5px " + color.toCSS))
                        expect(css["text-shadow-opacity"]).to(beNil())
                    }
                    
                    it("skips the everything when the opacity is 0.0 for " + String(describing: klass)) {
                        targetView.layer.shadowOpacity = 0.0
                        let css = ViewCSSShadowConfig.toCSS(object: targetView, base: "text")
                        expect(css["text-shadow"]).to(beNil())
                        expect(css["text-shadow-opacity"]).to(beNil())
                    }
                    
                    it("skips the color when nil for " + String(describing: klass)) {
                        targetView.layer.shadowColor = nil
                        let css = ViewCSSShadowConfig.toCSS(object: targetView, base: "text")
                        expect(css["text-shadow"]).to(equal("2px 3px 5px"))
                        expect(css["text-shadow-opacity"]).to(equal("0.6"))
                    }
                    
                    it("skips the radius when 0 for " + String(describing: klass)) {
                        targetView.layer.shadowRadius = 0.0
                        let css = ViewCSSShadowConfig.toCSS(object: targetView, base: "text")
                        expect(css["text-shadow"]).to(equal("2px 3px " + color.toCSS))
                        expect(css["text-shadow-opacity"]).to(equal("0.6"))
                    }
                })
            }
        }
    }
}
