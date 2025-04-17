#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>

using namespace std;
typedef unsigned int uint32;

// Function to get password input from user
string getPasswordFromUser() {
    string password;
    cout << "Enter password: ";
    cin >> password;
    return password;
}

// Function to apply SHA-256 padding and return padded byte array
vector<unsigned char> applyPadding(const string& input) {
    vector<unsigned char> message(input.begin(), input.end());

    size_t original_len_bits = message.size() * 8;
    message.push_back(0x80); // Append '1' bit

    while ((message.size() % 64) != 56) {
        message.push_back(0x00);
    }

    // Append 64-bit big-endian length
    for (int i = 7; i >= 0; --i) {
        message.push_back((original_len_bits >> (i * 8)) & 0xFF);
    }

    return message;
}

// Function to convert padded byte array to 32-bit words
vector<uint32> convertToWords(const vector<unsigned char>& bytes) {
    vector<uint32> words;
    for (size_t i = 0; i < bytes.size(); i += 4) {
        uint32 word = (bytes[i] << 24) |
                      (bytes[i + 1] << 16) |
                      (bytes[i + 2] << 8) |
                      (bytes[i + 3]);
        words.push_back(word);
    }
    return words;
}

// Function to write the words into my_file.mem
bool writeWordsToMemFile(const vector<uint32>& words, const string& filename = "my_file.mem") {
    ofstream memFile(filename);
    if (!memFile.is_open()) {
        cerr << "Failed to open " << filename << " for writing." << endl;
        return false;
    }

    for (uint32 word : words) {
        memFile << hex << setw(8) << setfill('0') << word << endl;
    }

    memFile.close();
    return true;
}

// Main function
int main() {
    string password = getPasswordFromUser();

    vector<unsigned char> paddedBytes = applyPadding(password);
    vector<uint32> words = convertToWords(paddedBytes);

    if (writeWordsToMemFile(words)) {
        cout << "Password successfully written to my_file.mem in SHA-256 padded format.\n";
    } else {
        cout << "Error writing to file.\n";
    }

    return 0;
}
