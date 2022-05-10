

Quem acompanha o vôlei feminino, provavelmente já ouviu falar na Athletes Unlimited, a liga profissional americana ( o famoso "rachão da Larson"). Para quem chegou até aqui saber o que é ou não sabe como aquela doideira funciona, recomendo fortemente o texto da [Débora Elisa](https://twitter.com/deboraelisa_) que pode ser lido [aqui](https://colunamista.com.br/como-funciona-athletes-unlimited-volleyball/) e vai ser muito mais fácil de entender do que eu tentando explicar.

E aí, depois da final da Superliga e o recorde de bloqueios da Carolana, eu me peguei pensando "tá, mas e se a Superliga fosse igual a AU, quem teria levado o prêmio?" e agora estamos aqui.

A AU é organizada de um jeito diferente da Superliga, o que facilita a pontuação maluca que eles fazem, como o número fixo de jogos e sets (apenas 3 e ganha quem fizer 75 pontos primeiro) e dificulta a equivalência exata com a Superliga. Além disso, eles consideram fundamentos diferentes. Por exemplo, eles levam em consideração o levantamento (acerto e erro), mas as estatísticas da Superliga não fornecem essa informação. Eles também consideram uma defesa de um ataque (*dig*, se bem sucedida, a jogadora ganha 5 pontos), mas também não temos essa informação com a Superliga (temos apenas a recepção, que na teoria seria depois de um saque e equivalente ao *pass* da AU). 

Logo, alguns ajustes foram necessários.

No manual de regras da AU (pode ser encontrado [aqui](https://auprosports.com/wp-content/uploads/2021/02/Athletes-Unlimited-Volleyball-Scoring-Sytstem-2.16.21.pdf)), eles explicam sobre as simulações que fizeram e como ajustaram a pontuação para ser mais justo. Afinal, se um ataque bem sucedido dá 12 pontos para a jogadora, coitada da líbero. Nunca chegaria perto. 

Então, tomei a liberdade de fazer alguns ajustes aqui também. Por exemplo, se uma jogadora é líbero, era ganha 5 pontos para cada recepção ao invés de apenas 2 das demais jogadoras. Infelizmente não foi possível fazer ajustes para todas as posições, porque não consigo no site da Superliga a informação sobre qual posição cada jogadora em cada jogo. Na AU, a jogadora ganha pontos se estiver no time que venceu o set, mas são 3 sets por jogos sempre. Como aqui podemos ter 5 e depende de cada jogo, não considerei sets vencidos na conra. 

A grande vencedora da AU é quem tiver mais pontos no total, porém todas as jogadoras jogam o mesmo número de jogos. Na Superliga temos a fase classificatória e os playoffs, o que deixa as coisas um pouco desbalanceadas. Para ser mais justa também com as atletas que se lesionaram, calculei a média por jogo.

Todas as informações sobre jogos da Superliga foram extraídas direto do [site](https://superliga.cbv.com.br/tabela-de-jogos-feminino?formato=rodada) CBV. O Viva Volêi foi uma coleta manual no [Instagram](https://www.instagram.com/cbvolei/) da CBV. A pontuação foi tirada da explicação no [site](https://auprosports.com/volleyball/how-we-play-volleyball/) da AU. A tabela abaixo mostra equivalência da AU com a Superliga que foi usada para os cálculos dessa brincadeira.
<center>

| AU               | Superliga                | Pontuação     |
|------------------|--------------------------|---------------|
| Service Error    | Serviço Err              | -8            |
| Service Ace      | Servico Ace              | 12            |
| Attack Kill      | Ataque Exc               | 8             |
| Attack Error     | Ataque Err + Ataque Blk  | -12           |
| Set Assist       |-                         | 1             |
| Set Error        |-                         | -12           |
| Dig              | Recepção Tot (L) - Erro  | 5             |
| Good Pass        | Recepção Tot - Erro      | 2             |
| Pass Error       | Recepção Err             | -12           |
| Block Stuff      | Bloqueio                 | 12            |
| Set Win          | -                        | 40            |
| Match Win        | Vencedor da partida      | 60            |
| MVP              | Viva vôlei               | 60            |

</center>



----
Quem tiver interesse em ver o código, está [aqui](https://github.com/smnlgn/superligasemlimites). E quem quiser falar sobre, pode me chamar no [Twitter](https://twitter.com/mynlugon).







