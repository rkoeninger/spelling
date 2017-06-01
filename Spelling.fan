class Spelling {

  ** Load sample text and offer corrections for input
  static Void main(Str[] args) {
    text := File.os("big.txt").readAllStr
    counts := Str:Int[:] { def = 0 }
    text.split.each |word| { counts[word] += 1 }
    totalSize := (Int)(counts.vals.reduce(0) |sum, x, i| { (Int)sum + x })
    echo(counts[args[0]])
  }

  static const Str letters := "abcdefghijklmnopqrstuvwxyz"

  ** Probability of `word`.
  static Float probability(Str:Int counts, Int totalSize, Str word) {
    counts[word] / totalSize.toFloat
  }

  ** Most probable spelling correction for `word`.
  static Str correction(Str:Int counts, Int totalSize, Str word) {
    candidates(counts, word).max |x, y| {
      probability(counts, totalSize, x) <=> probability(counts, totalSize, y)
    }
  }

  ** Generate possible spelling corrections for `word`.
  static Str[] candidates(Str:Int counts, Str word) {
    result := known(counts, Str[word])
    if (result.size > 0) return result

    result = known(counts, edits1(word))
    if (result.size > 0) return result

    result = known(counts, edits2(word))
    if (result.size > 0) return result

    return Str[word]
  }

  ** The subset of `words` that appear in the map of `counts`.
  static Str[] known(Str:Int counts, Str[] words) {
    words.findAll |word, i| { counts[word] > 0 }.unique
  }

  ** All edits that are one edit away from `word`.
  static Str[] edits1(Str word) {
    range := Range.makeInclusive(0, word.size)
    splits := range.map |i| {
      r1 := Range.makeInclusive(0, i)
      r2 := Range.makeExclusive(i, word.size)
      return Pair.make(word.getRange(r1), word.getRange(r2))
    }
    return Str[,]
  }

  ** All edits that are two edits away from `word`.
  static Str[] edits2(Str word) {
    (Str[])(edits1(word).map |w| { edits1(w) }.flatten)
  }
}

class Pair {
  new make(Obj? x, Obj? y) {
    this.x = x
    this.y = y
  }

  Obj? x
  Obj? y
}
