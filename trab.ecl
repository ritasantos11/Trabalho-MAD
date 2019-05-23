/*
Example input:

JAVA

X
ID Lsize li..Lj Dur Ntrab
ID Lsize li..Lj Dur Ntrab


X = nº de tarefas
ID = id da tarefa
Lsize = tamanho da lista de tarefas que só podem ter início depois da tarefa "ID" estar concluída
li..lj = ID's das várias tarefas que só podem ter início depois da tarefa "ID" estar concluída
Dur = Duração da tarefa
Ntrab = Nº de trabalhadores necessários para concluir a tarefa

*/

import java.util.*;

class Arco {
    int no_final;
    
    Arco(int fim){
	    no_final = fim;
    }

    int extremo_final() {
	    return no_final;
    }
}


class No {
    //int label;
    LinkedList<Arco> adjs;
    int duracao=0, trabalhadores=0;

    No() {
        adjs = new LinkedList<Arco>();
    }

}


class Grafo {
    No verts[];
    int nvs;
			
    public Grafo(int n) {
        nvs = n;
        verts  = new No[n+1];
        for (int i = 1; i <= n ; i++)
            verts[i] = new No();
    }
    
    public int num_vertices(){
	    return nvs;
    }

    public LinkedList<Arco> adjs_no(int i) {
	    return verts[i].adjs;
    }
    
    public void insert_new_arc(int i, int j){
	    verts[i].adjs.addFirst(new Arco(j));
    }
}

class Evento {
    int id, data, flag;

    Evento(int id, int data, int flag) {
        this.flag = flag;
        this.id = id;
        this.data = data;
    }

    public String toString() {
        return "(" + id + "," + data + "," + flag + ")";
    }

    // ordena os tuplos da LinkedList<Evento> conforme o 2º elemento do tuplo (a data da tarefa)
    public static LinkedList<Evento> ordenar(LinkedList<Evento> evento) {
        Collections.sort(evento, new Comparator<Evento>() {
            @Override
            public int compare(Evento evento1, Evento evento2) {
                return evento1.data - evento2.data;
            }
        });

        return evento;
    }
}


class P1 {
    // calcula o número de trabalhadores a contratar
    public static int numTrabalhadores(Grafo g, LinkedList<Evento> eventos) {
        int numT=0, max=numT, segundo, data, v;
        Evento evento = eventos.remove();
        
        while (!eventos.isEmpty()) {
            segundo = evento.data;
            data = segundo;

            while (segundo == data && !eventos.isEmpty()) {    
                v = evento.id;
            
                if (evento.flag==0)
                    numT += g.verts[v].trabalhadores;

                else
                    numT -= g.verts[v].trabalhadores;

                evento = eventos.remove();
                data = evento.data;
            }
            
            if (numT>max)
                max=numT;

        }

        return max;
    }



    public static void projeto(Grafo g, Grafo gt) {
        // método do caminho crítico (nó.atividade) - earliest start
        int numVerts = g.nvs;
        int es[] = new int[numVerts+1];
        int prec[] = new int[numVerts+1];
        int grauE[] = new int[numVerts+1];
        int v, w;

        for (v=1; v<=numVerts; v++) {
            es[v] = 0;
            prec[v] = 0;
            grauE[v] = 0;
        }

        for (v=1; v<=numVerts; v++) {
            LinkedList<Arco> adjs = g.adjs_no(v);
            for (Arco a : adjs) {
                w = a.extremo_final();
                grauE[w]++;
            }
        }

        LinkedList<Integer> s = new LinkedList<Integer>();
        for (v=1; v<=numVerts; v++)
            if (grauE[v]==0)
                s.add(v);

        int durMin = -1;
        int vf = 0;

        while (!s.isEmpty()) {
            v = s.remove();

            if (durMin < es[v] + g.verts[v].duracao) {
                durMin = es[v] + g.verts[v].duracao;
                vf = v;
            }

            LinkedList<Arco> adjs = g.adjs_no(v);
            for (Arco a : adjs) {
                w = a.extremo_final();

                if (es[w] < es[v] + g.verts[v].duracao) {
                    es[w] = es[v] + g.verts[v].duracao;
                    prec[w] = v;
                }

                grauE[w]--;

                if (grauE[w] == 0) {
                    s.add(w);

                }
            }
        }

        System.out.println("Duração Mínima do projeto: " + durMin);
        dur = durMin; //Duração mínima




        

        // nº trabalhadores a contratar
        LinkedList<Evento> eventos = new LinkedList<Evento>();
        int ef[] = new int[numVerts+1];
        for (v=1; v<=numVerts; v++) {
            Evento evento1 = new Evento(v,es[v],0);
            eventos.add(evento1);
            
            ef[v] = es[v] + g.verts[v].duracao;
            Evento evento2 = new Evento(v,ef[v],1);
            eventos.add(evento2);
        }

    
        LinkedList<Evento> eventosOrdenados = Evento.ordenar(eventos);
        int max = numTrabalhadores(g,eventosOrdenados);
        System.out.println("Número de trabalhadores necessários: " + max);

        high = max;





        // nº de trabalhadores para as atividades críticas
        int lf[] = new int[numVerts+1];
        int grauS[] = new int[numVerts+1];
        for (v=1; v<=numVerts; v++) {
            lf[v] = durMin;
            grauS[v] = 0;
        }

        for (v=1; v<=numVerts; v++) {
            LinkedList<Arco> adjs = gt.adjs_no(v);
            for (Arco a : adjs) {
                w = a.extremo_final();
                grauS[w]++;
            }
        }

        LinkedList<Integer> sAC = new LinkedList<>();
        for (v=1; v<=numVerts; v++)
            if (grauS[v]==0)
                sAC.add(v);

        while (!sAC.isEmpty()) {
            v = sAC.remove();

            LinkedList<Arco> adjs = gt.adjs_no(v);
            for (Arco a : adjs) {
                w = a.extremo_final();

                if (lf[w] > lf[v] - g.verts[v].duracao)
                    lf[w] = lf[v] - g.verts[v].duracao;
                
                grauS[w]--;

                if (grauS[w] == 0)
                    sAC.add(w);
            }
        }

        
        LinkedList<Integer> atividadesCriticas = new LinkedList<Integer>();
        int ls[] = new int[numVerts+1];
        for (v=1; v<=numVerts; v++) {
            ls[v] = lf[v] - g.verts[v].duracao;

            if (ls[v] == es[v])
                atividadesCriticas.add(v);
        }
        

        LinkedList<Evento> atvCriticas = new LinkedList<Evento>();
        int c;
        while (!atividadesCriticas.isEmpty()) {
            c = atividadesCriticas.remove();
            Evento critica1 = new Evento(c,es[c],0);
            atvCriticas.add(critica1);

            Evento critica2 = new Evento(c,ef[c],1);
            atvCriticas.add(critica2);
        }

        LinkedList<Evento> criticasOrdenadas = Evento.ordenar(atvCriticas);
        int maxAC = numTrabalhadores(g,criticasOrdenadas);        
        System.out.println("Número de trabalhadores para as atividades críticas " + maxAC);   

    }





    static int high; //número mínimo de trabalhadores - earliest start
    static int low;  //número mínimo de trabalhadores - tarefas críticas
    static int dur;  //duração mínima
    
    static int trab; //número mínimo de trabalhadores

    static void binarySearch(Grafo g) {
        int top = high;
        int bot = low;

        for(int i = 1; i <= g.nvs; i++) {
            if(g.verts[i].trabalhadores>bot)
                bot = g.verts[i].trabalhadores;
        }

        trab = bot + (top - bot) / 2;

        while(bot <= top) {
            int mid = bot + (top - bot) / 2;
            boolean sucesso = getSol(g, mid);
            if(sucesso) {
                trab = mid;
                top = mid - 1;
            }
            else
                bot = mid + 1;
        }
    }
    
    static boolean getSol(Grafo g, int val) {
        return true;
    }

    public static void main(String[] args) {
        Scanner stdin = new Scanner(System.in);

        int numVerts = stdin.nextInt();
        Grafo g = new Grafo(numVerts);
        // grafo transposto de g
        Grafo gt = new Grafo(numVerts);

        for (int i=1; i<=numVerts; i++) {
            int noA = stdin.nextInt();      //t1 tarefa

            int numSuc = stdin.nextInt();   //numero de tarefas em espera
            for (int j=0; j<numSuc; j++) {
                int no = stdin.nextInt();   //tarefa em espera da t1
                g.insert_new_arc(noA, no);
                gt.insert_new_arc(no, noA);
            }

            int duracao = stdin.nextInt();
            int numT = stdin.nextInt();
            g.verts[noA].duracao = duracao;
            g.verts[noA].trabalhadores = numT;

            gt.verts[noA].duracao = duracao;
            gt.verts[noA].trabalhadores = numT;
        }

        projeto(g,gt);
    }
}
