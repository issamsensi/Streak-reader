/// On web there is no local file system path to check; picked files are
/// handled in-memory, so never report a stored path as missing.
bool fileExists(String path) => true;
