//
//  UTI_Tests.swift
//  fseventstool
//
//  Created by Matthias Keiser on 10.01.17.
//  Copyright © 2017 Tristan Inc. All rights reserved.
//

import XCTest
import SwiftUTI

#if os(iOS)
	import MobileCoreServices
#elseif os(macOS)
	import CoreServices
    import AppKit
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

    // MARK: Tags

    func assertUTIIdentical(_ uti1: UTI, _ uti2: UTI) {

        XCTAssertTrue(uti1 == uti2)
        XCTAssertEqual(uti1.fileExtension, uti2.fileExtension)
        XCTAssertEqual(uti1.mimeType, uti2.mimeType)

        #if os(macOS)
        XCTAssertEqual(uti1.pbType, uti2.pbType)
        XCTAssertEqual(uti1.osType, uti2.osType)
        #endif
    }

    func testExtension() {

        let uti = UTI(withExtension: "pdf")
        assertUTIIdentical(uti, UTI.pdf)
    }

    func testMIMEType() {

        let uti = UTI(withMimeType: "application/pdf")
        assertUTIIdentical(uti, UTI.pdf)
    }

    #if os(macOS)

    func testPBType() {
        // The old Cocoa pasteboard types have been deprecated in favour of actual UTIs. We are using the content of
        // the old NSPDFPboardType to do this test.
        let uti = UTI(withPBType: "Apple PDF pasteboard type")
        assertUTIIdentical(uti, UTI.pdf)
    }

    func testOSType() {
        let uti = UTI(withOSType: "PDF ")
        assertUTIIdentical(uti, UTI.pdf)
    }

    #endif

	func testDynamic() {

		XCTAssertFalse(UTI.pdf.isDynamic)

		XCTAssertTrue(UTI(withExtension: "random_unknown_value_xxxxx").isDynamic)
	}

}
