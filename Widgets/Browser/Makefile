BUNDLE_NAME = Browser
Browser_FILES = Browser.m Web.m PrivateWebView.m Bookmark.m Add.m FolderItem.m FolderItemTableViewCell.m FolderItemController.m
Browser_INSTALL_PATH = /Library/ProWidgets/Widgets/
Browser_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Browser_PRIVATE_FRAMEWORKS = WebBookmarks
Browser_LIBRARIES = prowidgets
Browser_CFLAGS = -I../../
Browser_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)
Browser_BUNDLE_EXTENSION = widget

SUBPROJECTS = Substrate 

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk