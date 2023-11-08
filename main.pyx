# distutils: language = c++
# cython: profile=True
import nltk
from nltk.corpus import stopwords
from libcpp.vector cimport vector
from libcpp.string cimport string
from libc.math cimport*
from libcpp.algorithm cimport*
from libcpp.unordered_set cimport unordered_set

specChar = bytearray(b',.?!:;#$%()[]{}')
stopWords = []
stops = set(stopwords.words('english'))
for w in stops:
    stopWords.append(bytes(w, 'utf-8'))

cdef string deleteSpecChar(string word):

    cdef int i = 0
    cdef string empty
    for i in range(word.size()):
        if word[i] in specChar:
            word[i] = empty[0]


    return word

cdef vector[int] vectorize(vector[string] tokens, vector[string] merge):
    cdef vector[int] vecTxt
    for i in range(merge.size()):
        vecTxt.push_back(count(tokens.begin(), tokens.end(), merge[i]));

    return vecTxt

cdef double cosineSimilarity(vector[int] vector1, vector[int] vector2):
    cdef double cosSim = 0

    cdef double mul = 0.0, d_a = 0.0, d_b = 0.0;
    cdef int size = 0, i = 0

    size = vector1.size()
    for i in range(size):
        if (vector1[i]*vector2[i] != 0): mul += vector1[i] * vector2[i]
        d_a += vector1[i] * vector1[i]
        d_b += vector2[i] * vector2[i]

    cosSim = mul / (sqrt(d_a) * sqrt(d_b))
    return cosSim

def main():

    cdef int madiP = 0
    cdef double dobmadi = 0.4324253
    # Чтение файлов
    text1 = open("text1.txt", "r")
    readTxt1 = text1.read().encode('utf-8').lower()
    text1.close()

    text2 = open("text2.txt", "r")
    readTxt2 = text2.read().encode('utf-8').lower()
    text2.close()

    # Создаю вектор токенов
    cdef vector[string] tokens1
    cdef vector[string] tokens2

    # Делю на токены текст
    for w in readTxt1.split():
        w = deleteSpecChar(w)
        if w not in stopWords:
            tokens1.push_back(w)
    
    for w in readTxt2.split():
        w = deleteSpecChar(w)
        if w not in stopWords:
            tokens2.push_back(w)

    cdef vector[string] merge = tokens1
    merge.insert(merge.end(), tokens2.begin(), tokens2.end())

    cdef unordered_set[string] s
    for value in merge:
        s.insert(value)
    merge.assign(s.begin(), s.end());

    cdef vector[int] vecTxt1 = vectorize(tokens1, merge)
    cdef vector[int] vecTxt2 = vectorize(tokens2, merge)

    cdef double cosSim = cosineSimilarity(vecTxt1, vecTxt2)

    print(cosSim)

    return 0;