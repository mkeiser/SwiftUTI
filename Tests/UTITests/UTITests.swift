//
//  UTI_Tests.swift
//  fseventstool
//
//  Created by Matthias Keiser on 10.01.17.
//  Copyright © 2017 Tristan Inc. All rights reserved.
//

import XCTest

#if os(iOS)
	import MobileCoreServices
#elseif os(OSX)
	import CoreServices
#endif

class UTI_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEquality() {

		let uti1 = UTI(rawValue: kUTTypePDF as String)
		let uti2 = UTI.pdf
		let uti3 = UTI.rtf

		XCTAssertTrue(uti1 == uti2)
		XCTAssertTrue(uti2 == uti1)
		XCTAssertFalse(uti1 == uti3)
		XCTAssertFalse(uti2 == uti3)
	}

	func testConformance() {

		let uti1 = UTI.text
		let uti2 = UTI.rtf
		let uti3 = UTI.directory

		XCTAssertTrue( uti2.conforms(to: uti1) )
		XCTAssertFalse( uti1.conforms(to: uti2) )
		XCTAssertFalse( uti1.conforms(to: uti3) )
	}

	func testTags() {

		let uti1 = UTI.pdf

		var uti2 = UTI(withExtension: "pdf")
		XCTAssertTrue( uti1 == uti2 )

		uti2 = UTI(withMimeType: "application/pdf")
		XCTAssertTrue( uti1 == uti2 )

		#if os(macOS)
		uti2 = UTI(withPBType: NSPDFPboardType) // Note: NSPasteboardTypePDF doesn't work
		XCTAssertTrue( uti1 == uti2 )

		uti2 = UTI(withOSType: "PDF ")
		XCTAssertTrue( uti1 == uti2 )
		#endif

		XCTAssertEqual(uti1.fileExtension, uti2.fileExtension)
		XCTAssertEqual(uti1.mimeType, uti2.mimeType)

		#if os(macOS)
		XCTAssertEqual(uti1.pbType, uti2.pbType)
		XCTAssertEqual(uti1.osType, uti2.osType)
		#endif
	}

	func testDynamic() {

		XCTAssertFalse(UTI.pdf.isDynamic)

		XCTAssertTrue(UTI(withExtension: "random_unknown_value_xxxxx").isDynamic)
	}

}
