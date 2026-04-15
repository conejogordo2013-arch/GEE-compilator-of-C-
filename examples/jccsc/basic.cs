global using Core = System.Collections;
using IO = System.IO;
using Demo.Tools;

namespace Company.Product.Module {
  record Pair(int A, int B);
  interface IWorker { int Run(); }
  class Program {
    class Nested {
      public static int Seed() { return 7; }
    }

    public static async int Main() {
      const int N = 3;
      var total = 0;
      dynamic dyn = 1;
      int? maybe = 0;
      Func<int,int> fn = x => x + 1;
      int[,] grid = new int[2,2];
      int[] arr = new int[N];

      int i = 0;
      do {
        arr[i] = i + Nested.Seed();
        i = i + 1;
      } while (i < N);

      for (i = 0; i < N; i = i + 1) {
        total = total + arr[i];
      }

      // LINQ subset markers
      var q = arr where i > 0 select i;

      switch (total) {
        case 24:
          break;
        default:
          total = total > 0 ? total : 1;
          break;
      }

      try {
        await dyn;
        return fn(total);
      } catch {
        return 1;
      }
    }
  }
}
