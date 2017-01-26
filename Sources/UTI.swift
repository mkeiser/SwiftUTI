//
//  UTI.swift
//  fseventstool
//
//  Created by Matthias Keiser on 09.01.17.
//  Copyright © 2017 Tristan Inc. All rights reserved.
//

import Foundation

#if os(iOS)
	import MobileCoreServices
#elseif os(macOS)
	import CoreServices
#endif

public class UTI: RawRepresentable, Equatable {

	public enum TagClass: String {

		case fileExtension = "public.filename-extension" // kUTTagClassFilenameExtension
		case mimeType = "public.mime-type" //kUTTagClassMIMEType

		#if os (macOS)
		case pbType =  "com.apple.nspboard-type" //kUTTagClassNSPboardType
		case osType =  "com.apple.ostype" //kUTTagClassOSType
		#endif

		/// Convenience variable for internal use.
		fileprivate var rawCFValue: CFString {
			return self.rawValue as CFString
		}
	}

	public typealias RawValue = String

	public let rawValue: String


	/// Convenience variable for internal use.
	private var rawCFValue: CFString {

		return self.rawValue as CFString
	}

	/// This is the designated initializer of the UTI class.
	///
	/// - Parameter rawValue: A string that is a Universal Type Identifier, i.e. "com.foobar.baz" or a constant like kUTTypeMP3.
	/// - Returns: An UTI instance representing the specified rawValue.
	/// - Note: You should rarely use this method. The preferred way to initialize a known UTI is to use its static variable (i.e. UTI.PDF). You should make an extension to make your own types available as static variables.

	public required init(rawValue: UTI.RawValue) {

		self.rawValue = rawValue
	}

	/// Initialize an UTI with a tag of a specified class.
	///
	/// - Parameter withTagClass: The class of the tag.
	/// - Parameter value: The value of the tag.
	/// - Parameter conformingTo: If specified, the returned UTI must conform to this UTI. If nil is specified, this parameter is ignored. The default is nil.
	/// - Returns: An UTI instance representing the specified rawValue. If no known UTI with the specified tags is found, a dynamic UTI is created.
	/// - Note: You should rarely need this method. It's usually simpler to use one of the specialized initialzers like
	///  ```convenience init?(withExtension fileExtension: String, conformingTo conforming: UTI? = nil)```

	public convenience init(withTagClass tagClass: TagClass, value: String, conformingTo conforming: UTI? = nil) {

		let unamanagedIdentifier = UTTypeCreatePreferredIdentifierForTag(tagClass.rawCFValue, value as CFString, conforming?.rawCFValue)

		// UTTypeCreatePreferredIdentifierForTag only returns nil if the tag class is unknwown, which can't happen to us since we use an
		// enum of known values. Hence we can force-cast the result.

		let identifier = unamanagedIdentifier?.takeRetainedValue() as! String

		self.init(rawValue: identifier)
	}

	/// Initialize an UTI with a file extension.
	///
	/// - Parameter withExtension: The file extension (e.g. "txt").
	/// - Parameter conformingTo: If specified, the returned UTI must conform to this UTI. If nil is specified, this parameter is ignored. The default is nil.
	/// - Returns: An UTI corresponding to the specified values.

	public convenience init(withExtension fileExtension: String, conformingTo conforming: UTI? = nil) {

		self.init(withTagClass:.fileExtension, value: fileExtension, conformingTo: conforming)
	}

	/// Initialize an UTI with a MIME type.
	///
	/// - Parameter withMimeType: The MIME type (e.g. "text/plain").
	/// - Parameter conformingTo: If specified, the returned UTI must conform to this UTI. If nil is specified, this parameter is ignored. The default is nil.
	/// - Returns: An UTI corresponding to the specified values.

	public convenience init(withMimeType mimeType: String, conformingTo conforming: UTI? = nil) {

		self.init(withTagClass:.mimeType, value: mimeType, conformingTo: conforming)
	}

	#if os(macOS)

	/// Initialize an UTI with a pasteboard type.
	///
	/// - Parameter withPBType: The pasteboard type (e.g. NSPDFPboardType).
	/// - Parameter conformingTo: If specified, the returned UTI must conform to this UTI. If nil is specified, this parameter is ignored. The default is nil.
	/// - Returns: An UTI corresponding to the specified values.

	public convenience init(withPBType pbType: String, conformingTo conforming: UTI? = nil) {

		self.init(withTagClass:.pbType, value: pbType, conformingTo: conforming)
	}

	/// Initialize an UTI with a OSType.
	///
	/// - Parameter withOSType: The OSType type as a string (e.g. "PDF ").
	/// - Parameter conformingTo: If specified, the returned UTI must conform to this UTI. If nil is specified, this parameter is ignored. The default is nil.
	/// - Returns: An UTI corresponding to the specified values.
	/// - Note: You can use the variable ```OSType.string``` to get a string from an actual OSType.

	public convenience init(withOSType osType: String, conformingTo conforming: UTI? = nil) {

		self.init(withTagClass:.osType, value: osType, conformingTo: conforming)
	}

	#endif

	/// Returns the tag with the specified class.
	///
	/// - Parameter tagClass: The tag class to return.
	/// - Returns: The requested tag, or nil if there is no tag of the specified class.

	public func tag(with tagClass: TagClass) -> String? {

		let unmanagedTag = UTTypeCopyPreferredTagWithClass(self.rawCFValue, tagClass.rawCFValue)

		guard let tag = unmanagedTag?.takeRetainedValue() as? String else {
			return nil
		}

		return tag
	}

	/// Return the file extension that corresponds the the UTI. Returns nil if not available.

	public var fileExtension: String? {

		return self.tag(with: .fileExtension)
	}

	/// Return the MIME type that corresponds the the UTI. Returns nil if not available.

	public var mimeType: String? {

		return self.tag(with: .mimeType)
	}

	#if os(macOS)

	/// Return the pasteboard type that corresponds the the UTI. Returns nil if not available.

	public var pbType: String? {

		return self.tag(with: .pbType)
	}

	/// Return the OSType as a string that corresponds the the UTI. Returns nil if not available.
	/// - Note: you can use the ```init(with string: String)``` initializer to construct an actual OSType from the returnes string.

	public var osType: String? {

		return self.tag(with: .osType)
	}

	#endif

	/// Returns all tags of the specified tag class.
	///
	/// - Parameter tagClass: The class of the requested tags.
	/// - Returns: An array of all tags of the receiver of the specified class.

	public func tags(with tagClass: TagClass) -> Array<String> {

		let unmanagedTags = UTTypeCopyAllTagsWithClass(self.rawCFValue, tagClass.rawCFValue)

		guard let tags = unmanagedTags?.takeRetainedValue() as? Array<CFString> else {
			return []
		}

		return tags as Array<String>
	}

	/// Checks if the receiver conforms to a specified UTI.
	///
	/// - Parameter otherUTI: The UTI to which the receiver is compared.
	/// - Returns: ```true``` if the receiver conforms to the specified UTI, ```fals```otherwise.

	public func conforms(to otherUTI: UTI) -> Bool {

		return UTTypeConformsTo(self.rawCFValue, otherUTI.rawCFValue) as Bool
	}

	public static func ==(lhs: UTI, rhs: UTI) -> Bool {

		return UTTypeEqual(lhs.rawCFValue, rhs.rawCFValue) as Bool
	}

	public var description: String? {

		let unamanagedDescription = UTTypeCopyDescription(self.rawCFValue)

		guard let description = unamanagedDescription?.takeRetainedValue() as? String else {
			return nil
		}

		return description
	}

	public var declaration: [AnyHashable:Any]? {

		let unamanagedDeclaration = UTTypeCopyDeclaration(self.rawCFValue)

		guard let declaration = unamanagedDeclaration?.takeRetainedValue() as? [AnyHashable:Any] else {
			return nil
		}

		return declaration
	}

	public var declaringBundleURL: URL? {

		let unamanagedURL = UTTypeCopyDeclaringBundleURL(self.rawCFValue)

		guard let url = unamanagedURL?.takeRetainedValue() as? URL else {
			return nil
		}

		return url
	}

	/// Returns ```true``` if the receiver is a dynamic UTI.

	public var isDynamic: Bool {

		return self.rawValue.hasPrefix("dyn.")
	}

	/// Returns all UTIs that are associated with a specified tag.
	///
	/// - Parameters:
	///   - tag: The class of the specified tag.
	///   - value: The value of the tag.
	///   - conforming: If specified, the returned UTIs must conform to this UTI. If nil is specified, this parameter is ignored. The default is nil.
	/// - Returns: An array of all UTIs that satisfy the specified parameters.

	public static func utis(for tag: TagClass, value: String, conformingTo conforming: UTI? = nil) -> Array<UTI> {

		let unamanagedIdentifiers = UTTypeCreateAllIdentifiersForTag(tag.rawCFValue, value as CFString, conforming?.rawCFValue)


		guard let identifiers = unamanagedIdentifiers?.takeRetainedValue() as? Array<CFString> else {
			return []
		}

		return identifiers.flatMap { UTI(rawValue: $0 as String) }
	}
}

public extension UTI {

	//Generated like that:

	// cat /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Headers/UTCoreTypes.h | grep "extern const CFStringRef kUTType" | awk '{print "static let " substr($4, 8) " = UTI(rawValue: "$4" as String)"}' | column -t

	static  let  Item                        =  UTI(rawValue:  kUTTypeItem                        as  String)
	static  let  Content                     =  UTI(rawValue:  kUTTypeContent                     as  String)
	static  let  CompositeContent            =  UTI(rawValue:  kUTTypeCompositeContent            as  String)
	static  let  Message                     =  UTI(rawValue:  kUTTypeMessage                     as  String)
	static  let  Contact                     =  UTI(rawValue:  kUTTypeContact                     as  String)
	static  let  Archive                     =  UTI(rawValue:  kUTTypeArchive                     as  String)
	static  let  DiskImage                   =  UTI(rawValue:  kUTTypeDiskImage                   as  String)
	static  let  Data                        =  UTI(rawValue:  kUTTypeData                        as  String)
	static  let  Directory                   =  UTI(rawValue:  kUTTypeDirectory                   as  String)
	static  let  Resolvable                  =  UTI(rawValue:  kUTTypeResolvable                  as  String)
	static  let  SymLink                     =  UTI(rawValue:  kUTTypeSymLink                     as  String)
	static  let  Executable                  =  UTI(rawValue:  kUTTypeExecutable                  as  String)
	static  let  MountPoint                  =  UTI(rawValue:  kUTTypeMountPoint                  as  String)
	static  let  AliasFile                   =  UTI(rawValue:  kUTTypeAliasFile                   as  String)
	static  let  AliasRecord                 =  UTI(rawValue:  kUTTypeAliasRecord                 as  String)
	static  let  URLBookmarkData             =  UTI(rawValue:  kUTTypeURLBookmarkData             as  String)
	static  let  URL                         =  UTI(rawValue:  kUTTypeURL                         as  String)
	static  let  FileURL                     =  UTI(rawValue:  kUTTypeFileURL                     as  String)
	static  let  Text                        =  UTI(rawValue:  kUTTypeText                        as  String)
	static  let  PlainText                   =  UTI(rawValue:  kUTTypePlainText                   as  String)
	static  let  UTF8PlainText               =  UTI(rawValue:  kUTTypeUTF8PlainText               as  String)
	static  let  UTF16ExternalPlainText      =  UTI(rawValue:  kUTTypeUTF16ExternalPlainText      as  String)
	static  let  UTF16PlainText              =  UTI(rawValue:  kUTTypeUTF16PlainText              as  String)
	static  let  DelimitedText               =  UTI(rawValue:  kUTTypeDelimitedText               as  String)
	static  let  CommaSeparatedText          =  UTI(rawValue:  kUTTypeCommaSeparatedText          as  String)
	static  let  TabSeparatedText            =  UTI(rawValue:  kUTTypeTabSeparatedText            as  String)
	static  let  UTF8TabSeparatedText        =  UTI(rawValue:  kUTTypeUTF8TabSeparatedText        as  String)
	static  let  RTF                         =  UTI(rawValue:  kUTTypeRTF                         as  String)
	static  let  HTML                        =  UTI(rawValue:  kUTTypeHTML                        as  String)
	static  let  XML                         =  UTI(rawValue:  kUTTypeXML                         as  String)
	static  let  SourceCode                  =  UTI(rawValue:  kUTTypeSourceCode                  as  String)
	static  let  AssemblyLanguageSource      =  UTI(rawValue:  kUTTypeAssemblyLanguageSource      as  String)
	static  let  CSource                     =  UTI(rawValue:  kUTTypeCSource                     as  String)
	static  let  ObjectiveCSource            =  UTI(rawValue:  kUTTypeObjectiveCSource            as  String)
	static  let  SwiftSource                 =  UTI(rawValue:  kUTTypeSwiftSource                 as  String)
	static  let  CPlusPlusSource             =  UTI(rawValue:  kUTTypeCPlusPlusSource             as  String)
	static  let  ObjectiveCPlusPlusSource    =  UTI(rawValue:  kUTTypeObjectiveCPlusPlusSource    as  String)
	static  let  CHeader                     =  UTI(rawValue:  kUTTypeCHeader                     as  String)
	static  let  CPlusPlusHeader             =  UTI(rawValue:  kUTTypeCPlusPlusHeader             as  String)
	static  let  JavaSource                  =  UTI(rawValue:  kUTTypeJavaSource                  as  String)
	static  let  Script                      =  UTI(rawValue:  kUTTypeScript                      as  String)
	static  let  AppleScript                 =  UTI(rawValue:  kUTTypeAppleScript                 as  String)
	static  let  OSAScript                   =  UTI(rawValue:  kUTTypeOSAScript                   as  String)
	static  let  OSAScriptBundle             =  UTI(rawValue:  kUTTypeOSAScriptBundle             as  String)
	static  let  JavaScript                  =  UTI(rawValue:  kUTTypeJavaScript                  as  String)
	static  let  ShellScript                 =  UTI(rawValue:  kUTTypeShellScript                 as  String)
	static  let  PerlScript                  =  UTI(rawValue:  kUTTypePerlScript                  as  String)
	static  let  PythonScript                =  UTI(rawValue:  kUTTypePythonScript                as  String)
	static  let  RubyScript                  =  UTI(rawValue:  kUTTypeRubyScript                  as  String)
	static  let  PHPScript                   =  UTI(rawValue:  kUTTypePHPScript                   as  String)
	static  let  JSON                        =  UTI(rawValue:  kUTTypeJSON                        as  String)
	static  let  PropertyList                =  UTI(rawValue:  kUTTypePropertyList                as  String)
	static  let  XMLPropertyList             =  UTI(rawValue:  kUTTypeXMLPropertyList             as  String)
	static  let  BinaryPropertyList          =  UTI(rawValue:  kUTTypeBinaryPropertyList          as  String)
	static  let  PDF                         =  UTI(rawValue:  kUTTypePDF                         as  String)
	static  let  RTFD                        =  UTI(rawValue:  kUTTypeRTFD                        as  String)
	static  let  FlatRTFD                    =  UTI(rawValue:  kUTTypeFlatRTFD                    as  String)
	static  let  TXNTextAndMultimediaData    =  UTI(rawValue:  kUTTypeTXNTextAndMultimediaData    as  String)
	static  let  WebArchive                  =  UTI(rawValue:  kUTTypeWebArchive                  as  String)
	static  let  Image                       =  UTI(rawValue:  kUTTypeImage                       as  String)
	static  let  JPEG                        =  UTI(rawValue:  kUTTypeJPEG                        as  String)
	static  let  JPEG2000                    =  UTI(rawValue:  kUTTypeJPEG2000                    as  String)
	static  let  TIFF                        =  UTI(rawValue:  kUTTypeTIFF                        as  String)
	static  let  PICT                        =  UTI(rawValue:  kUTTypePICT                        as  String)
	static  let  GIF                         =  UTI(rawValue:  kUTTypeGIF                         as  String)
	static  let  PNG                         =  UTI(rawValue:  kUTTypePNG                         as  String)
	static  let  QuickTimeImage              =  UTI(rawValue:  kUTTypeQuickTimeImage              as  String)
	static  let  AppleICNS                   =  UTI(rawValue:  kUTTypeAppleICNS                   as  String)
	static  let  BMP                         =  UTI(rawValue:  kUTTypeBMP                         as  String)
	static  let  ICO                         =  UTI(rawValue:  kUTTypeICO                         as  String)
	static  let  RawImage                    =  UTI(rawValue:  kUTTypeRawImage                    as  String)
	static  let  ScalableVectorGraphics      =  UTI(rawValue:  kUTTypeScalableVectorGraphics      as  String)
	@available(OSX 10.12, *)
	static  let  LivePhoto                   =  UTI(rawValue:  kUTTypeLivePhoto                   as  String)
	static  let  AudiovisualContent          =  UTI(rawValue:  kUTTypeAudiovisualContent          as  String)
	static  let  Movie                       =  UTI(rawValue:  kUTTypeMovie                       as  String)
	static  let  Video                       =  UTI(rawValue:  kUTTypeVideo                       as  String)
	static  let  Audio                       =  UTI(rawValue:  kUTTypeAudio                       as  String)
	static  let  QuickTimeMovie              =  UTI(rawValue:  kUTTypeQuickTimeMovie              as  String)
	static  let  MPEG                        =  UTI(rawValue:  kUTTypeMPEG                        as  String)
	static  let  MPEG2Video                  =  UTI(rawValue:  kUTTypeMPEG2Video                  as  String)
	static  let  MPEG2TransportStream        =  UTI(rawValue:  kUTTypeMPEG2TransportStream        as  String)
	static  let  MP3                         =  UTI(rawValue:  kUTTypeMP3                         as  String)
	static  let  MPEG4                       =  UTI(rawValue:  kUTTypeMPEG4                       as  String)
	static  let  MPEG4Audio                  =  UTI(rawValue:  kUTTypeMPEG4Audio                  as  String)
	static  let  AppleProtectedMPEG4Audio    =  UTI(rawValue:  kUTTypeAppleProtectedMPEG4Audio    as  String)
	static  let  AppleProtectedMPEG4Video    =  UTI(rawValue:  kUTTypeAppleProtectedMPEG4Video    as  String)
	static  let  AVIMovie                    =  UTI(rawValue:  kUTTypeAVIMovie                    as  String)
	static  let  AudioInterchangeFileFormat  =  UTI(rawValue:  kUTTypeAudioInterchangeFileFormat  as  String)
	static  let  WaveformAudio               =  UTI(rawValue:  kUTTypeWaveformAudio               as  String)
	static  let  MIDIAudio                   =  UTI(rawValue:  kUTTypeMIDIAudio                   as  String)
	static  let  Playlist                    =  UTI(rawValue:  kUTTypePlaylist                    as  String)
	static  let  M3UPlaylist                 =  UTI(rawValue:  kUTTypeM3UPlaylist                 as  String)
	static  let  Folder                      =  UTI(rawValue:  kUTTypeFolder                      as  String)
	static  let  Volume                      =  UTI(rawValue:  kUTTypeVolume                      as  String)
	static  let  Package                     =  UTI(rawValue:  kUTTypePackage                     as  String)
	static  let  Bundle                      =  UTI(rawValue:  kUTTypeBundle                      as  String)
	static  let  PluginBundle                =  UTI(rawValue:  kUTTypePluginBundle                as  String)
	static  let  SpotlightImporter           =  UTI(rawValue:  kUTTypeSpotlightImporter           as  String)
	static  let  QuickLookGenerator          =  UTI(rawValue:  kUTTypeQuickLookGenerator          as  String)
	static  let  XPCService                  =  UTI(rawValue:  kUTTypeXPCService                  as  String)
	static  let  Framework                   =  UTI(rawValue:  kUTTypeFramework                   as  String)
	static  let  Application                 =  UTI(rawValue:  kUTTypeApplication                 as  String)
	static  let  ApplicationBundle           =  UTI(rawValue:  kUTTypeApplicationBundle           as  String)
	static  let  ApplicationFile             =  UTI(rawValue:  kUTTypeApplicationFile             as  String)
	static  let  UnixExecutable              =  UTI(rawValue:  kUTTypeUnixExecutable              as  String)
	static  let  WindowsExecutable           =  UTI(rawValue:  kUTTypeWindowsExecutable           as  String)
	static  let  JavaClass                   =  UTI(rawValue:  kUTTypeJavaClass                   as  String)
	static  let  JavaArchive                 =  UTI(rawValue:  kUTTypeJavaArchive                 as  String)
	static  let  SystemPreferencesPane       =  UTI(rawValue:  kUTTypeSystemPreferencesPane       as  String)
	static  let  GNUZipArchive               =  UTI(rawValue:  kUTTypeGNUZipArchive               as  String)
	static  let  Bzip2Archive                =  UTI(rawValue:  kUTTypeBzip2Archive                as  String)
	static  let  ZipArchive                  =  UTI(rawValue:  kUTTypeZipArchive                  as  String)
	static  let  Spreadsheet                 =  UTI(rawValue:  kUTTypeSpreadsheet                 as  String)
	static  let  Presentation                =  UTI(rawValue:  kUTTypePresentation                as  String)
	static  let  Database                    =  UTI(rawValue:  kUTTypeDatabase                    as  String)
	static  let  VCard                       =  UTI(rawValue:  kUTTypeVCard                       as  String)
	static  let  ToDoItem                    =  UTI(rawValue:  kUTTypeToDoItem                    as  String)
	static  let  CalendarEvent               =  UTI(rawValue:  kUTTypeCalendarEvent               as  String)
	static  let  EmailMessage                =  UTI(rawValue:  kUTTypeEmailMessage                as  String)
	static  let  InternetLocation            =  UTI(rawValue:  kUTTypeInternetLocation            as  String)
	static  let  InkText                     =  UTI(rawValue:  kUTTypeInkText                     as  String)
	static  let  Font                        =  UTI(rawValue:  kUTTypeFont                        as  String)
	static  let  Bookmark                    =  UTI(rawValue:  kUTTypeBookmark                    as  String)
	static  let  _3DContent                  =  UTI(rawValue:  kUTType3DContent                   as  String)
	static  let  PKCS12                      =  UTI(rawValue:  kUTTypePKCS12                      as  String)
	static  let  X509Certificate             =  UTI(rawValue:  kUTTypeX509Certificate             as  String)
	static  let  ElectronicPublication       =  UTI(rawValue:  kUTTypeElectronicPublication       as  String)
	static  let  Log                         =  UTI(rawValue:  kUTTypeLog                         as  String)
}

#if os(OSX)

	extension OSType {


		/// Returns the OSType encoded as a String.

		var string: String {

			let unmanagedString = UTCreateStringForOSType(self)

			return unmanagedString.takeRetainedValue() as String
		}


		/// Initializes a OSType from a String.
		///
		/// - Parameter string: A String representing an OSType.
		
		init(with string: String) {
			
			self = UTGetOSTypeFromString(string as CFString)
		}
	}
	
#endif
