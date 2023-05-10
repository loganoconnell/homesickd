#include <Foundation/Foundation.h>
#include <curl/curl.h>
#include <os/log.h>

static CURL *curl = NULL;

static os_log_t getHomeSickLog(void) {
    static dispatch_once_t once;
    static os_log_t log;
    
    // Ensures log is a singleton
    dispatch_once(&once, ^{
        log = os_log_create("com.logan.homesickd", "info");
    });

    return log;
}

static void printLog(const char *formatString, ...) {
    // Get ... args
    va_list args;
    va_start(args, formatString);
    
    NSString *message = [NSString stringWithFormat:[NSString stringWithUTF8String:formatString], args];
    
    // Print to syslog
    os_log(getHomeSickLog(), "%@", message);
    
    // Print to STDOUT (for debugging)
    printf("%s\n", message.UTF8String);

    va_end(args);
}


static void setupCURL() {
    curl = curl_easy_init();
    
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "https://www.apple.com/");
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5);
        
        // Attempt to send curl output to /dev/null to make STDOUT less noisy
        FILE *file = fopen("/dev/null", "w");
        
        if (file)
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, file);
        
        else
            printLog("We couldn't open /dev/null, so curl output will go to STDOUT");
    }
        
    else
        printLog("Couldn't initialize curl");
}

int main(int __unused argc, const char * __unused argv[]) {
    printLog("homesickd has started");
    
    setupCURL();
    
    if (!curl) {
        curl_easy_cleanup(curl);
        
        return -1;
    }
    
    else {
        CURLcode response;
        
        while (1) {
            response = curl_easy_perform(curl);
            
            if (response != CURLE_OK)
                printLog("curl failed with error: %s", curl_easy_strerror(response));
            
            else
                printLog("We found home; back in 1 minute");
            
            sleep(60);
        }
    }
    
    return 0;
}
