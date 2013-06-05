module MyFirstService {
    typedef string DNAString;
    typedef string ProteinString;
    funcdef translate_dna(DNAString dna) returns (ProteinString prot);
    funcdef store(DNAString dna) returns (int id) authentication required;
};
